cases = gets.strip.to_i
cases.times do
	rowcount = gets.strip.split(" ")[0].to_i
	grid = Array.new()
	rowcount.times do
		grid << gets.strip
	end
	
	rowcount = gets.strip.split(" ")[0].to_i
	pattern = Array.new()
	rowcount.times do
		pattern << gets.strip
	end
	
	potentialmatches = Array.new()
	grid.each_with_index do |row, index|
		match = row.match(pattern[0])
		potentialmatches << [index, match.offset(0)[0]] if match
	end
	
	output = "NO"
	
	if potentialmatches
		for potentialmatch in potentialmatches
			#slice out the piece that might match and then compare to the pattern
			if grid[potentialmatch[0], pattern.count].map {|row| row[potentialmatch[1], pattern[0].length]} == pattern
				output = "YES"
				break
			end
		end
	end
	
	puts output
	
end

