module PhoneNumber
	def self.clean(str)
		str ||= ""
		str.gsub(/[^*#0-9()+ -]/, '').gsub(/(.)\+/, '\1').squeeze(' ').strip
	end

	def self.normalize(str)
		str ||= ""
		clean(str).sub(/^\+/, '00').gsub(/[()+ -]/, '')
	end

	def self.denormalize(str)
		str ||= ""
		str = str.to_s.sub(/^00/, '+')
		if str =~ /^\+420/
			'+' + str[1..-1].scan(/.{1,3}/).join(' ')
		else
			str
		end
	end
end
