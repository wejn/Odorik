class AboutScreen < PM::GroupedTableScreen
	include PMSectionFooters

	title "About"._

	def get_header_view
		v = UIView.alloc.init

		bg = UIColor.alloc.initWithPatternImage(UIImage.imageNamed('bg'))
		v.backgroundColor = bg

		block = UIView.alloc.init

		iv = UIImageView.alloc.initWithImage(UIImage.imageNamed('Icon'))
		iv.layer.cornerRadius = 10.0
		iv.layer.masksToBounds = true

		app = UILabel.alloc.init.tap do |l|
			l.font = UIFont.boldSystemFontOfSize(18.0)
			l.backgroundColor = UIColor.clearColor
			l.textColor = UIColor.whiteColor
			l.text = NSBundle.mainBundle.infoDictionary["CFBundleDisplayName"]
		end

		ver = UILabel.alloc.init.tap do |l|
			l.font = UIFont.systemFontOfSize(14.0)
			l.backgroundColor = UIColor.clearColor
			l.textColor = UIColor.whiteColor
			l.text = ["Version"._, NSBundle.mainBundle.infoDictionary["CFBundleVersion"]].join(' ')
		end

		appver = UIView.alloc.init.tap do |av|
			Motion::Layout.new do |layout|
				layout.view av
				layout.subviews app: app, ver: ver
				layout.vertical "|[app][ver]|", 0
				layout.horizontal "|[app]|", 0
				layout.horizontal "|[ver]|", 0
			end
		end

		written = UILabel.alloc.init.tap do |l|
			l.font = UIFont.systemFontOfSize(14.0)
			l.backgroundColor = UIColor.clearColor
			l.textColor = UIColor.whiteColor
			l.text = "crafted with love by:"._
		end

		wejn = UIImageView.alloc.initWithImage(UIImage.imageNamed('wejn'))

		Motion::Layout.new do |layout|
			layout.view block
			layout.subviews icon: iv, appver: appver, written: written, wejn: wejn
			layout.vertical "|[icon]-[written]-[wejn]|", 0
			layout.horizontal "|[icon]-[appver]-(>=0)-|"
			layout.horizontal "|[written]-(>=0)-|"
			layout.horizontal "|[wejn]-(>=0)-|"
		end

		# Yay for https://github.com/evgenyneu/center-vfl
		Motion::Layout.new do |layout|
			layout.view v
			layout.subviews block: block, sv: v
			layout.vertical "[sv]-(<=0)-[block]"
			layout.horizontal "[sv]-(<=0)-[block]"
		end

		# FIXME: if I could only get rid of setframes...
		v.setFrame(CGRectMake(0, 0, 0, 300)) # don't even think of removing it
		std_border = 20
		std_spacer = 8
		elems = [iv.size.height, written.size.height, wejn.size.height]
		my_height = 2 * std_border + elems.inject(0) { |m,x| m+x } +
			(elems.size - 1) * std_spacer
		v.setFrame(CGRectMake(0, 0, 0, my_height))

		v
	end
	private :get_header_view

	def will_appear
		self.table_view.tableHeaderView = get_header_view
	end

	def table_data
		# from cache
		_td = @_table_data
		return _td unless _td.nil?
		# regenerate
		td = [{
				title: "\u00a0", # nbsp FTW
				cells: [{
					cell_identifier: "CenteredCell",
					cell_class: CenteredTableViewCell,
					title: "Acknowledgements"._,
					action: :acknowledgements,
				}, {
					cell_identifier: "CenteredCell",
					cell_class: CenteredTableViewCell,
					title: "E-mail Author"._,
					action: :contact_author,
				}, {
					cell_identifier: "CenteredCell",
					cell_class: CenteredTableViewCell,
					title: "Support website"._,
					action: :visit_website,
				}],
				footer: "\u00a9 2013 Wejn s.r.o.",

			}]
		@_table_data = td
	end

	def acknowledgements
		open AcknowledgementsScreen
	end

	def contact_author
		App.open_url("mailto:odorik@wejn.com")
	end

	def visit_website
		App.open_url("http://wejn.com/ios/odorik/"._)
	end
end
