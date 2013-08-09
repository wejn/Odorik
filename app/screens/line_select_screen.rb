class LineSelectScreen < PM::GroupedTableScreen
	title "Line Select"._

	refreshable callback: :on_refresh,
		pull_message: "Pull to refresh lines"._,
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

	def refresh_table_data
		# kill cache
		@lines = nil
		@_table_data = nil
		# refresh
		update_table_data
	end

	def table_data
		unless (_td = @_table_data).nil?
			_td # XXX: avoids race condition when bg thread kills @_table_data
		else
			td = [
				# Lines (from Odorik)
				{
					title: "Odorik's Lines"._,
					cells: (_li = @lines) || [
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
			]

			# Assign
			@_table_data = td

			# Call refresh if needed
			on_refresh(false) if _li.nil?

			# Return
			td
		end
	end

	def set_line(options = {})
		if options[:line]
			Odorik.line = options[:line] if @set_default
			close(options)
		end
	end

	def on_refresh(from_refresh = true)
		Dispatch::Queue.concurrent.async do
			# XXX: from refresh -> force
			li = Odorik.lines(from_refresh)
			oli = (li || []).map do |s|
				if s.kind_of?(String) && s =~ /^\d+$/
					{
						title: s,
						action: :set_line,
						arguments: { line: s },
						cell_identifier: "LineCell",
					}
				else
					nil
				end
			end.delete_if { |x| x.nil? }
			oli = [{
				title: "None useable. Refresh needed?"._,
				cell_class: InertTableViewCell,
				cell_identifier: "Inert",
			}] if oli.nil? || oli.empty?
			Dispatch::Queue.main.sync do
				end_refreshing if from_refresh
				@lines = oli
				@_table_data = nil
				update_table_data
			end
		end
	end
end
