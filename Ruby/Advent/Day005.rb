inputs = open("Day005-input.txt").readlines

total = 0
for input in inputs
	vowels = input.scan(/[aeiou]/).length
	doubleletters = input.scan(/(.)\1/).length
	naughtypairs = input.scan(/(ab)|(cd)|(pq)|(xy)/).length 

	if (vowels >= 3) & (doubleletters > 0) & (naughtypairs == 0)
		total += 1
	end
end

puts "First Phase:", total

total = 0
for input in inputs
	doublepairs = input.scan(/(..)(?:.*)\1/).length
	singlesurroundedwithdoubles = input.scan(/(.)(?:.)\1/).length

	if (doublepairs > 0) & (singlesurroundedwithdoubles > 0)
		total += 1
	end
end

puts "Second Phase:", total
