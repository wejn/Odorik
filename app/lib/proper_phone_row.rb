motion_require 'phone_number.rb'

module Formotion
	module RowType
		class ProperPhoneRow < PhoneRow
			def add_callbacks(field)
				super
				field.should_change? do |field, range, new_string|
					str = field.text.stringByReplacingCharactersInRange(range, withString: new_string).dup
					ns = PhoneNumber.clean(str)
					if str == ns
						true
					else
						field.setText ns
						false
					end
				end
			end
		end
	end
end
