require_relative 'cryptopals'

#answer should be 607648109
def reverseMT19937tempering(number)	
	puts number & 0xFFFFFFFF
	# Right shift by 18 bits and xor
	number = number ^ number >> 18
	puts number & 0xFFFFFFFF

	# Shift y left by 15 and take the bitwise and of y and 4022730752
	number = number ^ number << 15 & 0xefc60000 
	puts number & 0xFFFFFFFF

	# Shift y left by 7 and take the bitwise and of 2636928640
	number = number ^ number << 7 & 0x9d2c5680 
	puts number & 0xFFFFFFFF

	# Right shift by 11 bits
	number = number ^ number >> 11
	puts number & 0xFFFFFFFF

	return number & 0xFFFFFFFF
end

def MT19937tempering(number)
	puts number & 0xFFFFFFFF
	# Right shift by 11 bits
	number = number ^ number >> 11
	puts number & 0xFFFFFFFF

	# Shift y left by 7 and take the bitwise and of 2636928640
	number = number ^ number << 7 & 0x9d2c5680 
	puts number & 0xFFFFFFFF

	# Shift y left by 15 and take the bitwise and of y and 4022730752
	number = number ^ number << 15 & 0xefc60000 
	puts number & 0xFFFFFFFF

	# Right shift by 18 bits
	number = number ^ number >> 18
	puts number & 0xFFFFFFFF

	return number & 0xFFFFFFFF
end

prng = MT19937.new(1452230778)

outputs = []

624.times do outputs << prng.extractnumber end

puts "Tempering..."
MT19937tempering(2816742336)
puts

puts "Untempering..."
reverseMT19937tempering(outputs[0])


