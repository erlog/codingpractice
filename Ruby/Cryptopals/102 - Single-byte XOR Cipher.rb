
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

Base64Symbols = ("A".."Z").to_a + 
			("a".."z").to_a + 
			("0".."9").to_a + 
			["+","/"]

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

def singlebytexorhexstring(hexstring, xorbyte)
	hexstring = hexstring.scan(/.{2}/)
	output = ""
	hexstring.each do |hexchar| 
		output += (hexchar.to_i(16) ^ xorbyte).to_s(16) 
	end
	return output	
end

#input = ARGV[0]
input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736" 

i = 1
while (i < 256)
	output = hextostring(singlebytexorhexstring(input, i))
	if output.force_encoding("UTF-8").ascii_only?
		puts i.to_s(16) + ": " + output 
	end
	i += 1
end

