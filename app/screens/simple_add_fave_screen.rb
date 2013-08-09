class SimpleAddFaveScreen < PM::FormotionScreen
	include BW::KVO
	include FormotionGetRow

	title "Add favorite"._

	def on_create(args)
		args[:nav_bar] ||= true
		super(args)
	end

	def will_appear
		set_nav_bar_button :left, action: :dismiss, title: "Cancel"._,
			system_icon: UIBarButtonSystemItemCancel
		set_nav_bar_button :right, action: :save, title: "Save"._,
			system_icon: UIBarButtonSystemItemSave
		self.navigationItem.rightBarButtonItem.enabled = false
		@right_enabled = false
		@name_value = ""
		@phone_value = ""
	end

	def table_data
		@_table_data ||= {
			sections: [{
				rows: [{
					title: "Name"._,
					key: :name,
					placeholder: "John Doe"._,
					type: :string,
					auto_capitalization: :words,
				}, {
					title: "Phone"._,
					key: :phone,
					type: :proper_phone,
					placeholder: "+420 555 555 555",
				}, {
					title: "Phone label"._,
					key: :label,
					type: :picker,
					value: "default"._,
					items: %w[default mobile work home iPhone main other].map(&:_),
				}]
			}]
		}
	end

	def on_appear
		get_row(:name).tap do |row|
			observe(row, "value") do |ov, nv|
				@name_value = nv
				recalc_right_button
			end
		end
		get_row(:phone).tap do |row|
			observe(row, "value") do |ov, nv|
				@phone_value = nv
				recalc_right_button
			end
		end

	end

	def recalc_right_button
		if @name_value.empty? || @phone_value.empty?
			if @right_enabled
				self.navigationItem.rightBarButtonItem.enabled = false
				@right_enabled = false
			end
		else
			unless @right_enabled
				self.navigationItem.rightBarButtonItem.enabled = true
				@right_enabled = true
			end
		end
	end
	private :recalc_right_button

	def save
		fave = Favorite.new(self.form.render)
		Favorite.add!(fave)
		dismiss
	end

	def dismiss
		self.dismissModalViewControllerAnimated(true)
	end
end
