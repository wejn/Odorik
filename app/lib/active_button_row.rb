module Formotion
	module RowType
		class ActiveButtonRow < ButtonRow
			include BW::KVO

			def initialize(row)
				super(row)
				@_enabled = nil
			end
			attr_accessor :_enabled
			# XXX: don't use _enabled directly, you'll break things (KVO)

			def enable!
				self._enabled = true
			end

			def disable!
				self._enabled = false
			end

			def build_cell(cell)
				@_enabled = row.editable? if @_enabled.nil?
				set_status(cell, @_enabled)
				observe(self, "_enabled") do |ov, nv|
					set_status(cell, nv) unless ov == nv
				end
				observe(row, "title") do |ov, nv|
					unless ov == nv
						cell.textLabel.text = nv
						cell.layoutSubviews
					end
				end
				super(cell)
			end

			def set_status(cell, nv)
				cell.userInteractionEnabled = nv
				cell.selectionStyle = if nv
					UITableViewCellSelectionStyleBlue
				else
					UITableViewCellSelectionStyleNone
				end
				cell.textLabel.enabled = nv
				cell.enabled = nv
				self
			end
			private :set_status
		end
	end
end
