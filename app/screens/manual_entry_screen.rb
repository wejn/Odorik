# FIXME: make this screen less fugly, please. Pretty please.

motion_require 'proper_phone_row.rb'
motion_require 'phone_number.rb'

class ManualEntryScreen < PM::FormotionScreen
	include BW::KVO
	include FormotionGetRow

	title "Manual Entry"._

	def on_create(args)
		@animated_save = args.has_key?(:animated_save) ? args[:animated_save] : true
		@initial_value = PhoneNumber.clean(args[:initial_value] || "")

		super(args)
	end

	def will_appear
		set_nav_bar_button :left, action: :dismiss, title: "Cancel"._,
			system_icon: UIBarButtonSystemItemCancel
		set_nav_bar_button :right, action: :save, title: "Done"._,
			system_icon: UIBarButtonSystemItemDone
		@phone_value = @initial_value
		self.navigationItem.rightBarButtonItem.enabled = !@phone_value.empty?
		@right_enabled = !@phone_value.empty?
	end

	def on_appear
		get_row(:phone).tap do |row|
			observe(row, "value") do |ov, nv|
				@phone_value = nv
				# FIXME: how about looking the number up in AB?
				recalc_right_button
			end
			row.text_field.becomeFirstResponder
		end
	end

	def table_data
		@_table_data ||= {
			sections: [{
				rows: [{
					title: "Phone"._,
					value: @initial_value,
					key: :phone,
					type: :proper_phone,
					placeholder: "+420 555 555 555",
					auto_capitalization: :none,
					return_key: :done,
				}]
			}]
		}
	end

	def recalc_right_button
		if @phone_value.empty?
			if @right_enabled
				self.navigationItem.rightBarButtonItem.enabled = false
				@right_enabled = false
			end
		else
			unless @right_enabled
				self.navigationItem.rightBarButtonItem.enabled = true
				@right_enabled = true
			end
		end
	end
	private :recalc_right_button

	def dismiss
		close
	end

	def save
		close(:manual_entry => @phone_value, :animated => @animated_save)
	end
end
