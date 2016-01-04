require "base64"

Base64Symbols = ("A".."Z").to_a + 
			("a".."z").to_a + 
			("0".."9").to_a + 
			["+","/"]

input = ARGV[0]

def stringtohex(string)
	output = ""
	string.split("").each do |char| output += char.bytes[0].to_s(16) end
	return output
end

def hextostring(hexstring)
	hexstring = hexstring.scan(/.{2}/)
	output = ""
	hexstring.each do |hexchar| output += hexchar.to_i(16).chr end
	return output
end

def stringtobase64(string)
	return hextobase64(stringtohex(string))
end

def hextobase64(hexstring)
	#split hex values
	bitchunks = hexstring.scan(/.{2}/)
	#convert to padded binary
	bitchunks.map!{|x| x.to_i(16).to_s(2).rjust(8,"0")}
	#recombine and break into chunks of 6 binary values
	bitchunks = bitchunks.join("").split("").each_slice(6).to_a
	
	#rejoin the groups of 6 and pad the last sextet with zeroes
	bitchunks.map!(&:join)
	bitchunks[-1] = bitchunks[-1].ljust(6, "0")

	output = "" 
	bitchunks.each do |chunk|
		output += Base64Symbols[chunk.to_i(2)]
	end

	#communicate that we used padding
	remainder = output.length % 4
	if remainder == 3 then output += "="
	elsif remainder == 2 then output += "=="
	end

	return output
end

input = hextostring(input)
puts input
print "My algo: " + stringtobase64(input)
puts
print "Rb algo: " + Base64.encode64(input)
