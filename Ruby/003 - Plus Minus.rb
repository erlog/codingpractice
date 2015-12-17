length = 6
values = "-4 3 -9 0 4 1".split(' ').map(&:to_i)

pos = 0
neg = 0
zer = 0

values.each do |value|
	if value > 0 
		pos += 1
	elsif value < 0
		neg += 1
	else
		zer += 1
	end
end

puts "%.6f" % (pos/length.to_f)
puts "%.6f" % (neg/length.to_f)
puts "%.6f" % (zer/length.to_f)
