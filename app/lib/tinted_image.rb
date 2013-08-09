module TintedImage
	# adapted from http://stackoverflow.com/a/6078202/1177128
	def self.imageWithTint(name, color)
		src = UIImage.imageNamed(name)

		return nil if src.nil?

		rect = CGRectMake(0.0, 0.0, src.size.width, src.size.height)

		UIGraphicsBeginImageContext(rect.size)
		c = UIGraphicsGetCurrentContext()

		CGContextTranslateCTM(c, 0, src.size.height)
		CGContextScaleCTM(c, 1.0, -1.0)

		#src.drawInRect(rect)
		#CGContextDrawImage(c, rect, src.CGImage)
		# ^^ XXX: neither of those should be here. dunno why but it works

		colorSpace = CGColorSpaceCreateDeviceRGB()

		CGContextSetFillColorSpace(c, colorSpace)
		CGContextClipToMask(c, rect, src.CGImage)
		CGContextSetFillColorWithColor(c, color.CGColor)
		UIRectFillUsingBlendMode(rect, KCGBlendModeColor)

		img = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()
		CGColorSpaceRelease(colorSpace)

		img
	end
end
