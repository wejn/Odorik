motion_require 'active_button_row'

class AccountSettingsScreen < PM::FormotionScreen
	include BW::KVO
	include FormotionGetRow

	title "Account Settings"._

	def on_load
		OdorikAPIChangeCredsNotification.add_observer(self, :oaccn)
	end

	def oaccn
		Dispatch::Queue.main.async do
			refresh_table_data
		end
	end

	def on_appear
		setup_observers
	end

	def setup_observers
		get_row(:user).tap do |row|
			observe(row, "value") do |ov, nv|
				@user_value = nv
				recalc_state
			end
		end
		get_row(:pass).tap do |row|
			observe(row, "value") do |ov, nv|
				@pass_value = nv
				recalc_state
			end
		end
		get_row(:verify).tap do |row|
			row.on_tap do |el|
				row.object.disable!
				row.title = "Verifying ..."._
				Dispatch::Queue.concurrent.async do
					if Odorik.verify(@user_value, @pass_value)
						Odorik.use(@user_value, @pass_value)
						Dispatch::Queue.main.sync do
							row.title = "Verified & saved."._
						end
					else
						Dispatch::Queue.main.sync do
							row.title = "Verify failed. :-("._
							Dispatch::Queue.concurrent.async do
								sleep 2
								Dispatch::Queue.main.sync do
									recalc_state
								end
							end
						end
					end
				end
			end
		end
		recalc_state
		if Device.simulator?
			get_row(:reset).tap do |row|
				row.on_tap do |el|
					Odorik.reset! # XXX: will trigger #refresh_table_data
					App.delegate.configure_screens
				end
			end
		end
	end
	private :setup_observers

	def refresh_table_data
		update_table_data
		setup_observers
		recalc_state
	end

	def recalc_state
		get_row(:verify).tap do |row|
			row.title = "Verify"._
			if @user_value.empty? || @pass_value.empty? ||
					(ex = (@user_value == Odorik.user && @pass_value == Odorik.pass))
				row.object.disable!
				row.title = "Verified."._ if ex
			else
				row.object.enable!
			end
		end
	end
	private :recalc_state

	def table_data
		{
			title: "Account Settings"._,
			sections: [{
				footer: ("Username/password is to be found in Odorik's member section (Settings &rarr; Account&nbsp;settings &rarr; API&nbsp;password)."._ + "\n\n" + "You have to press the \"verify\" button below for any changes to take effect."._).gsub(/\&rarr;/, "\u2192").gsub(/\&nbsp;/, ' '),
				rows: [{
					title: "Username"._,
					key: :user,
					placeholder: "01234567",
					type: :string,
					auto_capitalization: :none,
					value: (@user_value = Odorik.user || ""),
				}, {
					title: "Password"._,
					key: :pass,
					placeholder: "abcdefghi",
					type: :string,
					auto_capitalization: :none,
					auto_correction: :no,
					secure: true,
					return_key: :done,
					value: (@pass_value = Odorik.pass || ""),
				}]
			}, {
				rows: [{
					title: 'Verify'._, # XXX: overriden in recalc_state
					type: :active_button,
					key: :verify,
					editable: false,
				}] + (Device.simulator? ? [{
					title: 'Reset'._,
					type: :button,
					key: :reset,
				}] : [])
			}]
		}
	end
end
