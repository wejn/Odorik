class WelcomeScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "Welcome!"._

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
		ab_as = AddressBook.authorization_status
		ab_enabled = ab_as == :not_determined
		ab_title = {
			:not_determined => "Configure"._,
			:restricted => "Restricted."._,
			:denied => "Denied."._,
			:authorized => "Granted."._,
		}[ab_as] || "Unknown."._

		my_red = BW.rgba_color(204, 46, 0, 1.0)
		my_grn = BW.rgba_color(46, 204, 0, 1.0)

		case ab_as
		when :restricted, :denied
			ab_image = TintedImage.imageWithTint('icons/46-no', my_red)
		when :authorized
			ab_image = TintedImage.imageWithTint('icons/258-checkmark', my_grn)
		else
			ab_image = nil
		end

		if Odorik.configured?
			od_image = TintedImage.imageWithTint('icons/258-checkmark', my_grn)
		else
			od_image = nil
	   end

		@_table_data ||= [
			{
				title: "1. Configure your Odorik Account"._,
				cells: [{
					cell_identifier: "RegularCell",
					title: Odorik.configured? ? "Configured."._ : "Configure"._,
					accessory_type: Odorik.configured? ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator,
					cell_class: EnableableTableViewCell,
					action: :configure_odorik,
					enabled: !Odorik.configured?,
					image: { image: od_image },
				}],
				footer: "This app requires valid Odorik account."._,
			}, {
				title: "2. Grant access to your contacts"._,
				cells: [{
					cell_identifier: "RegularCell",
					title: ab_title,
					accessory_type: !ab_enabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator,
					cell_class: EnableableTableViewCell,
					action: :configure_contacts,
					enabled: ab_enabled,
					image: { image: ab_image },
				}],
				footer: "Optional but recommended. Your addressbook data will be displayed to help you setup your calls quickly."._,
			}, {
				title: "3. Let's go!"._,
				cells: [{
					cell_identifier: "RegularCell",
					title: "Start"._,
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					cell_class: EnableableTableViewCell,
					action: :start_it_up,
					enabled: Odorik.configured?,
				}],
			}
		]
	end

	def configure_odorik
		open AccountSettingsScreen
	end

	def configure_contacts
		AddressBook.request_authorization
		refresh_table_data
	end

	def start_it_up
		App.delegate.configure_screens
	end
end
