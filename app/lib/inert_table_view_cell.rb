# Adds 'inert' table_view cell. That's a cell that's gray, centered
# and can't be selected (sel. style = none)
class InertTableViewCell < CenteredTableViewCell
	def setup(data_cell, what)
		data_cell[:title] ||= ''
		data_cell[:cell_identifier] ||= 'InertTableViewCell' # useless due to ProMotion::TableData#set_data_cell_defaults, yay
		super(data_cell, what)

		self.userInteractionEnabled = false
		self.textLabel.enabled = false
		self.selectionStyle = UITableViewCellSelectionStyleNone
	end
end
