class Acknowledgement
	def self.all
		if _ack = @_acknowledgements_cache_
			_ack
		else
			@_acknowledgements_cache_ = {
				"RubyMotion" => [:bsd2, "2012, HipByte SPRL and contributors"],
				"motion-testflight" => [:bsd2, "2012, Laurent Sansonetti <lrz@hipbyte.com>"],
				"bubble-wrap" => [:mit, "2012 Matt Aimonetti <matt.aimonetti@gmail.com>"],
				"motion-addressbook" => [:mit, "2012 Alex Rothenberg"],
				"ProMotion" => [:mit, "2013 Jamon Holmgren"],
				"sugarcube" => [:bsd2, "2012, RubyMotion Community.  http://github.com/rubymotion"],
				"formotion" => [:mit, "2012 Clay Allsopp <clay.allsopp@gmail.com>"],
				"afmotion" => [:mit, "2012 Clay Allsopp <clay.allsopp@gmail.com>"],
				"motion-cocoapods" => [:bsd2, "2012, Laurent Sansonetti <lrz@hipbyte.com>"],
				"cocoapods" => [:mit, ["2011 - 2012 Eloy Durán <eloy.de.enige@gmail.com>", "2012 Fabio Pelosin <fabiopelosin@gmail.com>"]],
				"motion-layout" => [:mit, "2013, Nick Quaranto"],
				"AFNetworking" => [:mit, "2011 Gowalla (http://gowalla.com/)"],
				"SVProgressHUD" => [:mit, "2011 Sam Vermette"],
				"Glyphish3 Pro" => [:custom, ["The awesome icons are Glyphish3 Pro."._, "", "See http://www.glyphish.com/"._]],
				"Odorik logo" => [:custom, ["Used with permission of miniTEL s.r.o."._, "", "Obtained from Jiří Kment <kment@odorik.cz>"._]],
				"helu" => [:mit, "2013 Ivan Acosta-Rubio <ivan@bakedweb.net>"],
			}.map do |k, v|
				Acknowledgement.new(name: k, type: v.first, copyright: v.last)
			end
		end
	end

	def initialize(opts = {})
		raise "required: name" unless opts[:name]
		@name = opts[:name]
		unless @license = opts[:license]
			raise "required: license OR type+copyright" unless opts[:type] && opts[:copyright]
			@license = get_license(opts[:type], opts[:copyright])
		end
	end

	attr_reader :name, :license

	def to_cell(action = :tapped_item)
		{
			cell_identifier: "AcknowledgementCell",
			cell_style: UITableViewCellStyleSubtitle,
			accessory_type: UITableViewCellAccessoryDisclosureIndicator,
			title: self.name,
			subtitle: self.license,
			action: action,
			arguments: self,
		}
	end

	private

	def get_license(type, copyright)
		out = []
		Array(copyright).each { |x| out << "Copyright \u00a9 " + x }
		case type
		when :mit, "mit"
			out << <<-EOF

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
			EOF
		when :bsd2, "bsd2"
			out << <<-EOF
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
			EOF
		when :custom
			out = Array(copyright)
		else
			raise "unknown license: #{type}"
		end
		out.join("\n")
	end
end
