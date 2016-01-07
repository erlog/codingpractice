require_relative 'cryptopals'

inputa = "ICE ICE BABY\x04\x04\x04\x04"
inputb = "ICE ICE BABY\x05\x05\x05\x05"
inputc = "ICE ICE BABY\x01\x02\x03\x04"

outputs = []
validoutput = [true, false, false]

[inputa, inputb, inputc].each do |input|
	valid = checkPKCS7padding(input.bytes) 
	if valid
		puts "Valid padding!"
	else
		puts "Invalid padding!"
	end
	outputs << valid 
end

puts "-----"
puts "Padding validation function test: "
testoutput(outputs, validoutput)
