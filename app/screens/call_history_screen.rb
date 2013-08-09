class CallHistoryCell < PM::TableViewCell
	def setup(data_cell, what)
		# do NOT use this/these:
		data_cell[:title] = ""
		data_cell[:subtitle] = ""
		# use these:
		data_cell[:text_phone] ||= ''
		data_cell[:text_label] ||= ''
		data_cell[:cell_identifier] ||= 'CallHistoryCell' # useless due to ProMotion::TableData#set_data_cell_defaults, yay

		super(data_cell, what)

		unless @_did_setup_cell
			# XXX: Beware of ProMotion's data_cell[:subviews] !
			# It is unusable for our purposes due to the fact it gets
			# removed/re-added on every cell reuse
			#
			# Not only that messes up constraints but it also kills
			# scrolling performance.
			#
			# Not that this is 100% smooth but it's certainly better.

			@_did_setup_cell = true
			@_all_lab = {
				text_phone: @phoneLabel = UILabel.alloc.init,
				text_label: @labelLabel = UILabel.alloc.init,
				text_more: @moreLabel = UILabel.alloc.init,
				text_date: @dateLabel = UILabel.alloc.init,
				text_price: @priceLabel = UILabel.alloc.init,
			}

			@_all_lab.each { |n,l| self.contentView.addSubview l }

			for _, label in @_all_lab
				label.textColor = UIColor.blackColor
				label.highlightedTextColor = UIColor.whiteColor
				label.font = UIFont.systemFontOfSize(14.0)
				label.translatesAutoresizingMaskIntoConstraints = false
			end

			@phoneLabel.font = UIFont.boldSystemFontOfSize(18.0)
			@labelLabel.textColor = UIColor.grayColor
			@moreLabel.font = UIFont.systemFontOfSize(18.0)
			@moreLabel.textColor = UIColor.grayColor
			@dateLabel.textAlignment = NSTextAlignmentRight # why needed?
			@dateLabel.textColor = BW.rgba_color(81, 102, 145, 1)
			@priceLabel.textAlignment = NSTextAlignmentRight # why needed?
			@priceLabel.textColor = BW.rgba_color(145, 102, 81, 1)

			Motion::Layout.new do |layout|
				layout.view self.contentView
				layout.subviews "phone" => @phoneLabel, "more" => @moreLabel, "label" => @labelLabel, "date" => @dateLabel, "price" => @priceLabel
				layout.metrics "vm" => 2, "hm" => 8
				layout.vertical "|-vm-[phone]-(>=0)-[label]-vm-|"
				layout.vertical "|-vm-[date]-(>=0)-[price]-vm-|"
				layout.vertical "|-vm-[more]-(>=0,>=vm)-|"
				layout.horizontal "|-hm-[phone(>=180@450)]-(hm@400,>=1@450,<=8)-[more]-(>=4@400)-[date(>=80@450)]-hm-|"
				#layout.horizontal "|-hm-[phone]-(hm@400,>=1@450,<=8)-[more]-(>=4@400)-[date]-hm-|"
				layout.horizontal "|-hm-[label(>=120@450)]-(>=0)-[price(>=50@450)]-hm-|"
				#layout.horizontal "|-hm-[label]-(>=0)-[price]-hm-|"
			end
		end

		bg = self.backgroundColor
		for name, label in @_all_lab
			label.backgroundColor = bg
			label.text = data_cell[name] || ''
		end
	end

	def self.intelligent_date(time)
		td = time.kind_of?(Time) ? time : Time.iso8601(time)
		n = Time.now
		secs_in_day = 24*3600
		if td.today?
			td.strftime("%H:%M")
		elsif (n.start_of_day - 1.days) <= td # yday?
			"Yesterday"._
		elsif (n.start_of_day - 7.days) <= td # last week?
			td.strftime("%A")._
		else
			td.strftime("%d.%m")
		end
	end

	def self.to_cell(item, action = :tapped_item)
		if item['direction'] == 'in'
			field = 'source_number'
			if item['status'] == 'missed'
				bg = "#ffeeee".uicolor
			else
				bg = '#eeeeff'.uicolor
			end
		else
			field = 'destination_number'
			bg = '#eeffee'.uicolor
		end
		return nil if PhoneNumber.normalize(item[field]) == PhoneNumber.normalize(Odorik.caller) # FIXME: configurable
		phone = PhoneNumber.denormalize(item[field] || "??")
		time = Time.iso8601(item['date'])
		{
			cell_identifier: "CallHistoryCell", # FUCK YOU, ProMotion
			cell_class: CallHistoryCell,
			background_color: bg,
			text_phone: phone, # FIXME: translate to contacts and listen for changes in AB via: ABAddressBookRegisterExternalChangeCallback
			text_price: (("%.02f" % item["price"]) || "??").to_s,
			text_more: "", # FIXME: "(X)" when grouping
			text_label: "...", # FIXME: when resolving write label here
			text_date: intelligent_date(time),
			action: action,
			arguments: {
				item: item,
				phone: phone,
				date: time,
			},
		}
	end
end

class CallHistoryScreen < PM::TableScreen
	title "Recents"._
	tab_bar_item title: "Call History"._, icon: "icons/11-clock.png"

	refreshable callback: :on_refresh,
		pull_message: "Pull to refresh history"._,
		refreshing: "Refreshing..."._,
		updated_format: "Last updated at %s"._,
		updated_time_format: "%l:%M %p"._

	def on_appear
		fetch_table_data
	end

	def on_return(options = {})
		fetch_table_data
	end

	def table_data
		_td = @_table_data
		return _td unless _td.nil? || _td.empty?
		# do NOT set @_table_data if you have nothing interesting to show
		[{
			cells: [
				{
					cell_class: InertTableViewCell,
					cell_identifier: "Inert",
				}, {
					title: "Loading..."._,
					cell_class: InertTableViewCell,
					cell_identifier: "Inert",
				}, {
					cell_class: InertTableViewCell,
					subviews: [ AutoCenteringActivityIndicator.new ],
					cell_identifier: "Inert",
				},
			]
		}]
	end

	def fetch_table_data(force_reload = false, from_refresh = false)
		Dispatch::Queue.concurrent.async do
			# FIXME: dates configurable?
			data = if Odorik.configured?
				Odorik.calls(Time.now-31*24*3600, Time.now+24*3600, force_reload)
			else
				"Account not configured."._
			end
			if data.nil? || data.kind_of?(String)
				cells = [{
					cells: [
						{
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}, {
							title: "Failure to fetch call history"._,
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}, {
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}]
				}]
				if data.kind_of?(String)
					cells.first[:cells] += [
						{
							title: "API returned error:"._,
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}, {
							title: data,
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}
					]
				end
			else
				if data.empty?
					cells = [{
						cells: [
							{
								cell_class: InertTableViewCell,
								cell_identifier: "Inert",
							}, {
								title: "No call history, yet."._,
								cell_class: InertTableViewCell,
								cell_identifier: "Inert",
							},
						]
					}]
				else
					cells = [{
						cells: data.map { |item| CallHistoryCell.to_cell(item) }.
							delete_if { |x| x.nil? }
					}]
				end
			end
			Dispatch::Queue.main.sync do
				@_table_data = cells
				end_refreshing if from_refresh
				update_table_data
			end
		end
	end

	def on_refresh
		fetch_table_data(true, true)
	end

	def tapped_item(options = {})
		app_delegate.call_out(options[:phone]) if options[:phone]
	end
end
