module PMSectionFooters
	# XXX: this would be awesome if it was part of ProMotion itself
	def tableView(tableView, titleForFooterInSection:section)
		(table_data[section] || {})[:footer]
	end
end
