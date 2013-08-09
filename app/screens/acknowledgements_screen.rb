class AcknowledgementsScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "Acknowledgements#Title"._

	def table_data
		# from cache
		_td = @_table_data
		return _td unless _td.nil?
		# regenerate
		td = [{
			title: "This app happily uses:"._,
			cells: Acknowledgement.all.map(&:to_cell),
			footer: "If I forgot to attribute you, I apologize in advance. Please contact me and I will rectify it immediately."._,
		}]
		@_table_data = td
	end

	def tapped_item(item)
		open AcknowledgementDetailScreen.new(ack: item)
	end
end
