cases = gets.strip.to_i

for i in (0..cases-1)
	cycles = gets.strip.to_i
	height = 1
	
	for i2 in (0..cycles-1)
		height *= 2 if i2.even?
		height += 1 if i2.odd?
	end
	
	puts height
end

