class CallerSelectScreen < PM::GroupedTableScreen
	title "Caller Select"._

	refreshable callback: :on_refresh,
		pull_message: "Pull to refresh allowed senders"._,
		refreshing: "Refreshing..."._,
		updated_format: "Last updated at %s"._,
		updated_time_format: "%l:%M %p"._

	def on_create(args)
		@set_default = args.has_key?(:set_default) ? args[:set_default] : true

		super(args)
	end

	def on_load
		OdorikAPIChangeCredsNotification.add_observer(self, :oaccn)
	end

	def oaccn
		Dispatch::Queue.main.async do
			refresh_table_data
		end
	end

	def on_return(options = {})
		if options[:manual_entry]
			set_caller(caller: options[:manual_entry])
		end
	end

	def refresh_table_data
		# kill cache
		@allowed_senders = nil
		@_table_data = nil
		# refresh
		update_table_data
	end

	def table_data
		unless (_td = @_table_data).nil?
			_td # XXX: avoids race condition when bg thread kills @_table_data
		else
			td = []

			# Allowed senders (from Odorik)
			td << {
				title: "Odorik's Allowed Senders"._,
				cells: (_as = @allowed_senders) || [
					{
						title: "Loading..."._,
						cell_class: InertTableViewCell,
						cell_identifier: "Inert",
					}, {
						cell_class: InertTableViewCell,
						cell_identifier: "Inert",
						subviews: [ AutoCenteringActivityIndicator.new ],
					},
				]
			}
			# Faves
			unless Favorite.all.empty?
				td << {
					title: "Favorites"._,
					cells: Favorite.all.map { |f|
						{
							cell_style: UITableViewCellStyleSubtitle,
							cell_identifier: "FavoriteCell",
							cell_class: PM::TableViewCell,
							title: f.name,
							subtitle: f.label,
							action: :set_caller,
							arguments: { caller: f.phone },
						}
					},
				}
			end

			# Others
			td << {
				title: "Other sources"._,
				cells: [{
					cell_identifier: "OtherSourcesCell",
					title: "From contacts"._,
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					enabled: AddressBook.authorized?,
					action: :caller_from_ab,
				}, {
					cell_identifier: "OtherSourcesCell",
					title: "Entered manually"._,
					accessory_type: UITableViewCellAccessoryDisclosureIndicator,
					action: :caller_from_manual,
				}]
			}

			# Assign
			@_table_data = td

			# Call refresh if needed
			on_refresh(false) if _as.nil?

			# Return
			td
		end
	end

	def set_caller(options = {})
		if options[:caller]
			Odorik.caller = options[:caller] if @set_default
			close(options)
		end
	end

	def on_refresh(from_refresh = true)
		Dispatch::Queue.concurrent.async do
			# XXX: from refresh -> force
			as = Odorik.sms_allowed_sender(from_refresh)
			osas = (as || []).map do |s|
				if s.kind_of?(String) && s =~ /^00/
					n = s.gsub(/^00/, '+')
					{
						title: n,
						action: :set_caller,
						arguments: { caller: n },
						cell_identifier: "AllowedSenderCell",
					}
				else
					nil
				end
			end.delete_if { |x| x.nil? }
			osas = [{
				title: "None useable. Refresh needed?"._,
				cell_class: InertTableViewCell,
				cell_identifier: "Inert",
			}] if osas.nil? || osas.empty?
			Dispatch::Queue.main.sync do
				end_refreshing if from_refresh
				@allowed_senders = osas
				@_table_data = nil
				update_table_data
			end
		end
	end

	def caller_from_ab
		return unless AddressBook.authorized? # one can't be cautious enough
		ab_scr = ContactsScreen.new(
			keep_cancel: true,
			close_on_cancel: true,
			prompt: "Choose a number to use as Caller"._,
			phone_select_cb: ->(person, property, id) do
				set_caller(caller: person.phone_values[id])
				false
			end,
			close_after_select: true
		)
		open ab_scr, modal: true
	end

	def caller_from_manual
		open ManualEntryScreen.new(animated_save: false)
	end
end
