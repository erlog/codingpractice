height = 6

line = Array.new(height)
line.map! {|n| n = " "}

for i in (0..height-1).reverse_each
	line[i] = "#"
	line.each {|n| print n}
	if i > 0
		print "\n"
	end
end
