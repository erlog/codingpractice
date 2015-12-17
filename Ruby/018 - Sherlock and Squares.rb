#require 'math'
cases = gets.strip.to_i

cases.times do
	min, max = gets.strip.split(" ").map! {|s| s.to_i}
	total = 0
	i = 1
	squares = Array.new()
	while total < 10**9
		total = i*i
		squares << total
		i += 1
	end
	
	count = 0
	
	for square in squares
		count += 1 if square >= min and square <= max
		break if square > max
	end
	
	puts count
end


