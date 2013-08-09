class AppDelegate < PM::Delegate
	def on_load(app, options)
		configure_screens
	end

	def configure_screens
		unless Odorik.configured?
			open WelcomeScreen.new(nav_bar: true)
		else
			@faves ||= FavoritesScreen.new(nav_bar: true)
			@recents ||= CallHistoryScreen.new(nav_bar: true)
			if AddressBook.authorized?
				@contacts ||= ContactsScreen.new(phone_select_cb: ->(person, prop, id) do
					fave = Favorite.from_ab(person, id)
					app_delegate.call_out(fave) if fave
					false
				end)
			else
				@contacts = nil
			end
			@call_out ||= CallOutScreen.new(nav_bar: true)
			@settings ||= SettingsScreen.new(nav_bar: true)
			ar = [@faves, @recents, @contacts, @call_out, @settings]
			ar.delete_if(&:nil?)
			@tbc = open_tab_bar *ar
		end
	end

	def call_out(item)
		if @call_out
			@call_out.set_callee(item) if item
			open_tab @call_out.tabBarItem.tag
		else
			App.alert("Can't call out"._, { message: "CallOutScreen not initialized!"._ })
		end
	end
end
