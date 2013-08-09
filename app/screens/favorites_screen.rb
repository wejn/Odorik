FavoritesReloadNotification = "FavoritesScreen#reloadFaves"

class FavoritesScreen < PM::TableScreen
	title "Favorites#Title"._
	if Supporter.is?
		tab_bar_item title: "Favorites#TabName"._, icon: "icons/29-heart"
	else
		tab_bar_item title: "Favorites#TabName"._, icon: "icons/28-star"
	end

	def on_load
		set_nav_bar_button :right, action: :add_fave, title: "Add"._,
			system_icon: UIBarButtonSystemItemAdd

		@editing = false
		my_set_left_nav_button

		FavoritesReloadNotification.add_observer(self, :fetch_table_data)
		FavoritesReloadNotification.post_notification
		SupporterDonatedNotification.add_observer(self, :supporter_donated)
	end

	def supporter_donated
		Dispatch::Queue.main.async do
			set_tab_bar_item title: "Favorites#TabName"._, icon: "icons/29-heart"
		end
	end

	def add_fave
		if AddressBook.authorized?
			af_scr = ContactsScreen.new(
				keep_cancel: true,
				close_on_cancel: true,
				prompt: "Choose a contact to add to Favorites"._,
				phone_select_cb: ->(person, property, id) do
					Favorite.add_from_ab!(person, id)
					false
				end,
				close_after_select: true
			)
		else
			af_scr = SimpleAddFaveScreen.new
		end
		open af_scr, modal: true
	end

	def toggle_editing
		@editing = !@editing
		self.view.setEditing(@editing, animated: true)
		my_set_left_nav_button
	end

	def table_data
		_td = @_table_data
		return _td unless _td.nil? || _td.empty?
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
					cell_identifier: "Inert",
					subviews: [ AutoCenteringActivityIndicator.new ],
				},
			]
		}]
	end

	def my_set_left_nav_button
		act = :toggle_editing
		if @editing
			title = "Done"._
			icon = UIBarButtonSystemItemDone
		else
			title = "Edit"._
			icon = UIBarButtonSystemItemEdit
		end
		set_nav_bar_button :left, title: title, system_icon: icon, action: act
	end
	private :my_set_left_nav_button

	def fetch_table_data
		Dispatch::Queue.concurrent.async do
			if Device.simulator? # FIXME: remove
				unless @__fetch_table_data_initial_slowdown_done__
					@__fetch_table_data_initial_slowdown_done__ = true
					sleep 2
				end
			end
			data = Favorite.all
			data ||= []
			if data.empty?
				cells = [{
					cells: [
						{
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						}, {
							title: "No favorites, yet."._,
							cell_class: InertTableViewCell,
							cell_identifier: "Inert",
						},
					]
				}]
			else
				cells = [{
					cells: data.map { |item| item.to_cell(:tapped_item) }
				}]
			end
			Dispatch::Queue.main.sync do
				@_table_data = cells
				update_table_data
			end
		end
	end

	def tapped_item(item)
		app_delegate.call_out(item)
	end

	def tableView(table_view, moveRowAtIndexPath: from, toIndexPath: to)
		Favorite.move(from.row, to.row)
	end

	def on_cell_deleted(cell)
		if cell[:cell_class] == InertTableViewCell
			false
		elsif cell[:arguments].kind_of?(Favorite)
			Favorite.delete(cell[:arguments])
		else
			false
		end
	end
end
