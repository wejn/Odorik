class AcknowledgementDetailScreen < PM::Screen
	title "Detail"._

	def on_create(args)
		@acknowledgement = args[:ack]
		super(args)
	end

	def on_load
		self.view.backgroundColor = UIColor.whiteColor
		#self.title = @acknowledgement ? @acknowledgement.name : "???"

		name = UILabel.alloc.init.tap do |l|
			l.font = UIFont.boldSystemFontOfSize(18.0)
			l.textAlignment = UITextAlignmentCenter
			l.text = @acknowledgement ? @acknowledgement.name : "???"
		end

		text = UITextView.alloc.init.tap do |l|
			l.editable = false
			l.text = @acknowledgement ? @acknowledgement.license : "???"
		end

		Motion::Layout.new do |layout|
			layout.view self.view
			layout.subviews name: name, text: text
			layout.vertical "|-[name]-[text]-|"
			layout.horizontal "|-[name]-|", 0
			layout.horizontal "|-[text]-|", 0
		end
	end
end
