# Auto-centers activity indicator within superview
#
# FIXME: will it work if superview resized?
class AutoCenteringActivityIndicator < UIActivityIndicatorView
	def self.new(opts = {})
		style = opts[:style] || UIActivityIndicatorViewStyleGray
		s = self.alloc.initWithActivityIndicatorStyle(style)
		s.startAnimating unless opts[:dont_start]
		s.autoresizingMask = (
			UIViewAutoresizingFlexibleLeftMargin |
			UIViewAutoresizingFlexibleRightMargin |
			UIViewAutoresizingFlexibleTopMargin |
			UIViewAutoresizingFlexibleBottomMargin)
		s
	end

	def didMoveToSuperview
		super
		if self.superview
			self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2,
				CGRectGetHeight(self.superview.bounds)/2)
		end
	end
end
