class StartCallbackCell < EnableableTableViewCell
	def setup(data_cell, what)
		data_cell[:image] ||= UIImage.imageNamed('icons/75-phone.png')
		data_cell[:cell_identifier] ||= "StartCallbackCell" # useless due to ProMotion::TableData#set_data_cell_defaults, yay
		data_cell[:selection_style] = data_cell[:disabled_style] = 
			data_cell[:enabled_style] = UITableViewCellSelectionStyleNone

		@am_i_enabled = false

		super(data_cell, what)

		self.textLabel.textColor = UIColor.whiteColor
		self.textLabel.textAlignment = UITextAlignmentCenter
	end

	def enable
		super
		@am_i_enabled = true
		self.imageView.alpha = 1.0
		# FIXME: not a proper way to do this.
	end

	def disable
		super
		@am_i_enabled = false
		self.imageView.alpha = 0.3
		# FIXME: not a proper way to do this.
	end

	# oh PM 1.0, how I love you...
	def restyle!
		setHighlighted(false, animated: false)
	end

	def setHighlighted(hl, animated: an)
		super(hl, animated: an)
		if hl
			self.backgroundColor = BW.rgba_color(32,102, 0, 1.0)
		else
			if @am_i_enabled
				self.backgroundColor = BW.rgba_color(46, 204, 0, 1.0)
			else
				self.backgroundColor = UIColor.grayColor
			end
		end
	end
end

class CallOutScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "Setup Callback"._
	tab_bar_item title: "Dial"._, icon: "icons/75-phone.png"

	refreshable callback: :on_refresh,
		pull_message: "Pull to refresh balance"._,
		refreshing: "Refreshing..."._,
		updated_format: "Last updated at %s"._,
		updated_time_format: "%l:%M %p"._


	def on_load

		OdorikAPIChangeCredsNotification.add_observer(self, :oaccrn)
		OdorikAPIChangeLineNotification.add_observer(self, :oacln)
		OdorikAPIChangeCallerNotification.add_observer(self, :oaccan)
	end

	def oaccrn
		Dispatch::Queue.main.async do
			refresh_table_data
		end
	end

	def oacln
		Dispatch::Queue.main.async do
			refresh_line
		end
	end

	def oaccan
		Dispatch::Queue.main.async do
			refresh_caller
		end
	end

	def on_return(options = {})
		if options[:caller] || options[:line] || options[:manual_entry]
			@caller = options[:caller] if options.has_key?(:caller)
			@line = options[:line] if options.has_key?(:line)
			if options[:manual_entry] && ! options[:manual_entry].empty?
				@callee = options[:manual_entry]
				# FIXME: how about looking the number up in AB?
				# (or perhaps straight on ManualEntry)
			end
			fetch_balance(true)
			refresh_table_data
		end
	end

	def will_appear
		@become_active_obs = App.notification_center.observe UIApplicationDidBecomeActiveNotification do |notification|
			fetch_balance(true)
		end
	end

	def will_disappear
		if @become_active_obs
			App.notification_center.unobserve @become_active_obs
		end
	end

	def on_appear
		fetch_balance
	end

	def refresh_line
		@line = nil
		refresh_table_data
	end

	def refresh_caller
		@caller = nil
		refresh_table_data
	end

	def refresh_table_data
		@_table_data = nil # kill cache
		update_table_data
=begin
		# if you ever want to add balance to NavigationBar
		# (but you have to adjust font size)
		if @balance
			self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(UILabel.alloc.initWithFrame(CGRectZero).tap { |x| x.text = "12%s CZK" % @balance; x.sizeToFit; x.backgroundColor = UIColor.clearColor; x.textColor = UIColor.whiteColor })
		else
			self.navigationItem.rightBarButtonItem = nil
		end
=end
	end

	def callee_name
		return @callee.name if @callee && @callee.respond_to?(:name)
		#return @callee.to_s if @callee && @callee.respond_to?(:to_s)
		""
	end
	private :callee_name

	def callee_phone
		return @callee.phone if @callee && @callee.respond_to?(:phone)
		return @callee.to_s if @callee && @callee.respond_to?(:to_s)
		""
	end
	private :callee_phone

	def callee_photo
		return @callee.photo if @callee && @callee.respond_to?(:photo)
		nil
	end
	private :callee_photo

	def caller_phone
		@caller || Odorik.caller
	end
	private :caller_phone

	def line_number
		@line || Odorik.line
	end
	private :line_number

	def table_data
		unless (_td = @_table_data).nil?
			_td # XXX: avoids race condition when bg thread kills @_table_data
		else
			td = []

			unless Odorik.configured?
				td << {
					title: "Error"._,
					cells: [{
						title: "Odorik not configured"._,
						cell_class: InertTableViewCell,
						cell_identifier: "Inert",
					}]
				}
			else
				td << {
					title: "Who to call"._,
					cells: [{
						title: callee_phone,
						subtitle: callee_name,
						image: { image: callee_photo },
						# XXX: don't use straight "image: callee_photo"
						# because ProMotion will reuse cell and keep the
						# old image set. Ouch.
						cell_class: EnableableTableViewCell,
						cell_style: UITableViewCellStyleSubtitle,
						cell_identifier: "WhoToCallCell",
						accessory_type: UITableViewCellAccessoryDisclosureIndicator,
						enabled: Odorik.configured?,
						action: :open_callee_select,
					}]
				}

				td << {
					title: "Additional details"._,
					footer: "Caller is the \"first leg\" of the callback, line determines caller ID."._,
					cells: [{
						title: "Caller"._,
						subtitle: caller_phone,
						cell_class: EnableableTableViewCell,
						cell_style: UITableViewCellStyleValue1,
						cell_identifier: "CallerCell",
						accessory_type: UITableViewCellAccessoryDisclosureIndicator,
						enabled: Odorik.configured?,
						action: :open_caller_select,
					}, {
						title: "Line"._,
						subtitle: line_number,
						cell_class: EnableableTableViewCell,
						cell_style: UITableViewCellStyleValue1,
						cell_identifier: "LineCelll",
						accessory_type: UITableViewCellAccessoryDisclosureIndicator,
						enabled: Odorik.configured?,
						action: :open_line_select,
					}]
				}
				td << {
					cells: [{
						title: "Setup callback"._,
						cell_identifier: "StartCallbackCell",
						cell_class: StartCallbackCell,
						action: :setup_callback,
						enabled: !callee_phone.empty?,
					}]
				}
				if @balance
					td.last[:footer] = "Available balance: %s CZK"._ % [@balance]
				else
					td.last[:footer] = "Available balance: checking..."._
				end

				@_table_data = td
			end
		end
	end

	def open_callee_select
		open ManualEntryScreen.new(initial_value: callee_phone)
	end

	def open_caller_select
		open CallerSelectScreen.new(set_default: false)
	end

	def open_line_select
		open LineSelectScreen.new(set_default: false)
	end

	def set_callee(item)
		@callee = item
		refresh_table_data
	end

	def clean_number(num)
		num.gsub(/[^0-9+*#]/, '').sub(/^\+/, '00').gsub(/\+/, '')
	end
	private :clean_number

	def setup_callback
		SVProgressHUD.showWithStatus "Setting up callback..."._, maskType: SVProgressHUDMaskTypeBlack
		Dispatch::Queue.concurrent.async do
			_callee = PhoneNumber.normalize(callee_phone)
			_caller = PhoneNumber.normalize(caller_phone)
			_line = PhoneNumber.normalize(line_number)
			cb = "invalid number"._ if _callee.empty?
			cb ||= Odorik.callback(_caller, _callee, _line, 0)
			Dispatch::Queue.main.sync do
				if cb
					SVProgressHUD.dismiss
					App.alert("Callback failed"._, { message: "Response from API:"._ + "\n" + cb })
				else
					SVProgressHUD.showSuccessWithStatus "Expect incoming."._
				end
			end
		end
	end

	def on_refresh
		fetch_balance(true, true)
	end

	def fetch_balance(reload = false, from_refresh = false)
		if @last_balance_refresh && Time.now - @last_balance_refresh < 30
			reload = false
			# avoid burdening API with too frequent calls
			# FIXME: is 30s enough?
		end
		Dispatch::Queue.concurrent.async do
			ba = Odorik.balance(reload)
			Dispatch::Queue.main.sync do
				@last_balance_refresh = Time.now if reload || @balance.nil?
				@balance = ba || "??.??"
				end_refreshing if from_refresh
				refresh_table_data
			end
		end
	end
	private :fetch_balance
end
