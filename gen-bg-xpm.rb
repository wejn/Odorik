#!/usr/bin/env ruby

$tile_size = 10
$border_size = $tile_size / 10.0
$tiles = 20

out = []

def add_tile(lines, color, border = '.')
	lines.each_with_index do |l, i|
		if i < $border_size || i >= lines.size - $border_size
			$tile_size.times { l << border }
		else
			$border_size.floor.to_i.times { l << border }
			($tile_size - 2*$border_size).to_i.times { l << color }
			$border_size.ceil.to_i.times { l << border }
		end
	end
end

colors = {
	"a" => "#3D444D",
	"b" => "#3E464F",
	"c" => "#404651",
	"d" => "#424852",
	"e" => "#434A53",
	"f" => "#454C55",
	"g" => "#464E57",
	"h" => "#49505B",
	"i" => "#48505B",
	"j" => "#474D57",
	"k" => "#444B56",
	"l" => "#414952",
	"m" => "#3F4750",
}
color_keys = colors.keys
colors['.'] = "#3C424C"

last = 0
1.upto($tiles) do |x|
	lines = Array.new($tile_size) { Array.new }
	1.upto($tiles) do |y|
		#add_tile(lines, color_keys[rand(color_keys.size)])
		last = (last + rand(7)) % color_keys.size
		add_tile(lines, color_keys[last])
	end
	out += lines
end

puts <<-EOF
/* XPM */
static char *image[] = {
"#{$tile_size*$tiles} #{$tile_size*$tiles} #{colors.size} 1",
EOF
for name, value in colors
	puts "\"#{name} c #{value}\","
end
for line in out
	puts "\"" + line.join + "\","
end
puts "};"

# ./gen-bg-xpm.rb > bg.xpm
# convert bg.xpm bg.png
# convert bg.png -scale 400x400 bg@2x.png
