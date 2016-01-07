require_relative 'cryptopals'

inputa = "ICE ICE BABY\x04\x04\x04\x04"
inputb = "ICE ICE BABY\x05\x05\x05\x05"
inputc = "ICE ICE BABY\x01\x02\x03\x04"

def validatepadding(string)
	padlength = string.bytes[-1]
	properpadding = Array.new(padlength){padlength}
	realpadding = string.bytes[(padlength*-1)..-1]
	if realpadding == properpadding
		return true
	else
		raise "Invalid padding."	
	end
end

outputs = []
validoutput = [true, false, false]
begin
	validatepadding(inputa)
	puts "Valid padding!"
	outputs << true
rescue RuntimeError
	puts "Invalid padding!"
	outputs << false
end

begin
	validatepadding(inputb)
	puts "Valid padding!"
	outputs << true
rescue RuntimeError
	puts "Invalid padding!"
	outputs << false
end

begin
	validatepadding(inputc)
	puts "Valid padding!"
	outputs << true
rescue RuntimeError
	puts "Invalid padding!"
	outputs << false
end

puts "-----"
puts "Padding validation function test: "
testoutput(outputs, validoutput)
