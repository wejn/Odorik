class CenteredTableViewCell < PM::TableViewCell
	def setup(data_cell, what)
		data_cell[:title] ||= ''
		data_cell[:cell_identifier] ||= 'CenteredTableViewCell' # useless due to ProMotion::TableData#set_data_cell_defaults, yay
		super(data_cell, what)

		self.textLabel.textAlignment = UITextAlignmentCenter
	end
end
