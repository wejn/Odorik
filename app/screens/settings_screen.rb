class SettingsScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "Settings"._
	tab_bar_item title: "Settings"._, icon: "icons/20-gear-2.png"

	def on_load
		OdorikAPIChangeCredsNotification.add_observer(self, :oaccn)
	end

	def oaccn
		Dispatch::Queue.main.async do
			refresh_table_data
		end
	end

	def on_return(options = {})
		# XXX: need unconditional refresh b/c of return from AccountSettings
		refresh_table_data
	end

	def refresh_table_data
		@_table_data = nil # XXX: kill cache
		update_table_data
	end

	def table_data
		# from cache
		_td = @_table_data
		return _td unless _td.nil?
		# regenerate
		td = [
			{
				title: "Odorik.cz API Access"._,
				cells: [{
					cell_identifier: "RegularCell",
					title: "Account"._,
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					action: :open_account_settings,
				}]
			}, {
				title: "Phone number configuration"._,
				footer: "Caller and Line are defaults you can temporarily override on Dial screen (until next app restart)."._,
				cells: [{
					title: "Caller"._,
					subtitle: Odorik.caller || 'none'._,
					cell_class: EnableableTableViewCell,
					cell_style: UITableViewCellStyleValue1,
					cell_identifier: "Enableable",
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					enabled: Odorik.configured?,
					action: :open_caller_select,
				}, {
					title: "Line"._,
					subtitle: Odorik.line || 'default'._,
					cell_class: EnableableTableViewCell,
					cell_style: UITableViewCellStyleValue1,
					cell_identifier: "Enableable",
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					enabled: Odorik.configured?,
					action: :open_line_select
				}]
			}]
		unless AddressBook.authorized?
			ab_as = AddressBook.authorization_status
			ab_enabled = ab_as == :not_determined
			ab_title = {
				:not_determined => "Configure"._,
				:restricted => "Restricted."._,
				:denied => "Denied."._,
				:authorized => "Granted."._,
			}[ab_as] || "Unknown."._
			td << {
				title: "Contacts access"._,
				cells: [{
					cell_identifier: "RegularCell",
					title: ab_title,
					accessory_type: !ab_enabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator,
					cell_class: EnableableTableViewCell,
					action: :configure_contacts,
					enabled: ab_enabled,
				}],
			}
			if [:restricted, :denied].include?(ab_as)
				td.last[:footer] = "If you previously denied access, you need to grant it in Settings &rarr; Privacy &rarr; Contacts."._.gsub(/\&rarr;/, "\u2192")
			end
		end

		td << {
			title: "This app"._,
			cells: [{
				cell_identifier: "RegularCell",
				title: "About this app"._,
				accessory_type: UITableViewCellAccessoryDisclosureIndicator,
				action: :open_about,
			}, {
				cell_identifier: "RegularCell",
				title: "Rate this app"._,
				accessory_type: UITableViewCellAccessoryDisclosureIndicator,
				action: :open_rate,
			}, {
				cell_identifier: "RegularCell",
				title: "Settings#Reward author"._,
				accessory_type: UITableViewCellAccessoryDisclosureIndicator,
				action: :open_reward,
			}],
		}
		@_table_data = td
	end

	def open_account_settings
		open AccountSettingsScreen
	end

	def open_caller_select
		open CallerSelectScreen
	end

	def open_line_select
		open LineSelectScreen
	end

	def open_about
		open AboutScreen
	end

	def configure_contacts
		AddressBook.request_authorization
		refresh_table_data
		App.delegate.configure_screens
	end

	def open_rate
		if appid = NSBundle.mainBundle.infoDictionary['X_ITUNES_APP_ID']
			App.open_url("itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + appid.to_s)
		else
			App.alert("Can't rate app"._, { message: "I don't know my own APP_ID, would you believe that?"._ })
		end
	end

	def open_reward
		open RewardAuthorScreen
	end
end
