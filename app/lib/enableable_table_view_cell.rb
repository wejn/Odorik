# Extracted from LabeledTableViewCell
class EnableableTableViewCell < PM::TableViewCell
	def setup(data_cell, what)
		data_cell[:title] ||= ''
		data_cell[:cell_identifier] ||= 'EnableableTableViewCell' + (data_cell[:enabled] ? "Enabled" : "Disabled") # useless due to ProMotion::TableData#set_data_cell_defaults, yay

		super(data_cell, what)

		@disabled_style = data_cell[:disabled_style] || UITableViewCellSelectionStyleNone
		@enabled_style = data_cell[:enabled_style] || UITableViewCellSelectionStyleBlue

		if data_cell[:enabled]
			enable
		else
			disable
		end

	end

	attr_accessor :enabled_style, :disabled_style

	def enable
		self.selectionStyle = self.enabled_style
		self.userInteractionEnabled = true
		self.textLabel.enabled = true
		self.detailTextLabel.enabled = true if self.detailTextLabel
	end

	def disable
		self.selectionStyle = self.disabled_style
		self.userInteractionEnabled = false
		self.textLabel.enabled = false
		self.detailTextLabel.enabled = false if self.detailTextLabel
	end
end
