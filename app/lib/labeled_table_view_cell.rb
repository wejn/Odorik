# Adds table_view cell that has label as accessory and can be easily
# enabled/disabled (grayed out, etc).
#
# Plus it will auto-style the accessory label by main element via KVO.
#
# XXX: Update: Essentially I'm reimplementing UITableViewCellStyleValue1
#      with the added benefit of enabling/disabling a cell. Oh my. :-(
#
# XXX: Don't use unless you really need it;
#      use EnableableTableViewCell instead.
class LabeledTableViewCell < PM::TableViewCell
	include BW::KVO

	def setup(data_cell, what)
		data_cell[:title] ||= ''
		data_cell[:cell_identifier] ||= 'LabeledTableViewCell' + (data_cell[:enabled] ? "Enabled" : "Disabled") # useless due to ProMotion::TableData#set_data_cell_defaults, yay
		data_cell[:accessory] ||= {}

		if data_cell[:accessory][:view]
			if data_cell[:accessory][:view].kind_of?(UILabel)
				@ltvc_label = data_cell[:accessory][:view]
			else
				@ltvc_label = nil
			end
		else
			@ltvc_label = UILabel.alloc.init
		end
		data_cell[:accessory][:view] = @ltvc_label
		set_label(data_cell[:label_text] || "")

		super(data_cell, what)

		@disabled_style = data_cell[:disabled_style] || UITableViewCellSelectionStyleNone
		@enabled_style = data_cell[:enabled_style] || UITableViewCellSelectionStyleBlue
		if data_cell[:enabled]
			enable
		else
			disable
		end

		if @ltvc_label
			for i in %w[textColor highlightedTextColor]
				@ltvc_label.send(i + "=", self.textLabel.send(i))
				observe(self.textLabel, i) do |old, newv|
					@ltvc_label.send(i + "=", newv)
				end
			end

			# XXX: why oh why do I have to keep 'highlighted' separate?
			# save for the getter, that much I get (no pun intended)
			@ltvc_label.highlighted = self.textLabel.isHighlighted
			observe(self.textLabel, "highlighted") do |old, newv|
				@ltvc_label.highlighted = newv
			end
		end

		self
	end

	attr_accessor :enabled_style, :disabled_style

	def enable
		self.selectionStyle = self.enabled_style
		self.userInteractionEnabled = true
		self.textLabel.enabled = true
		@ltvc_label.enabled = true if @ltvc_label
	end

	def disable
		self.selectionStyle = self.disabled_style
		self.userInteractionEnabled = false
		self.textLabel.enabled = false
		@ltvc_label.enabled = false if @ltvc_label
	end

	def set_label(label)
		if @ltvc_label
			@ltvc_label.text = label
			@ltvc_label.sizeToFit
		end
		self
	end
end
