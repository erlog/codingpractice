def hexstringtobytearray(hexstring)
	bytearray = hexstring.scan(/.{2}/)
	bytearray.map!{ |hex| hex.to_i(16) }
	return bytearray
end

def bytearraytohexstring(bytearray)
	bytearray.map!{ |hex| hex.to_s(16).rjust(2, "0")}
	return bytearray.join
end

def bytearraytostring(bytearray)
	begin
		return bytearray.map(&:chr).join
	rescue RangeError
		return ""
	end
end

def stringtobytearray(string)
	return string.bytes
end

Base64Symbols = ("A".."Z").to_a +
			("a".."z").to_a +
			("0".."9").to_a +
			["+","/"]

def bytearraytobase64(bytearray)
	#convert to padded binary
	bytearray.map!{|x| x.to_s(2).rjust(8,"0")}
	#recombine and break into chunks of 6 binary values
	bitchunks = bytearray.join.split("").each_slice(6).to_a

	#rejoin the groups of 6 and pad the last sextet with zeroes
	bitchunks.map!(&:join)
	bitchunks[-1] = bitchunks[-1].ljust(6, "0")

	#convert the sextets to base64 symbols and join them into a string
	bitchunks.map!{ |chunk| Base64Symbols[chunk.to_i(2)]}
	output = bitchunks.join

	#communicate padding
	remainder = output.length % 4
	if remainder == 3 then output += "="
	elsif remainder == 2 then output += "=="
	end

	return output
end

def base64tobytearray(base64string)
	bytearray = []
	base64string.split("").each do |char| 
		bytearray << Base64Symbols.index(char).to_s(2)
	end

	bytearray = bytearray.join

	return bytearray
end

def fixedxor(bytearray, xorbytes)
	output = []
	bytearray.zip(xorbytes).each do |a, b|
		output << (a ^ b)
	end

	return output
end

def singlebytexor(bytearray, xorbyte)
	output = bytearray.map{ |byte| (byte ^ xorbyte)}
	return output
end

def repeatingkeyxor(bytearray, xorbytes)
	output = []
	bytearray.zip(xorbytes.cycle).each do |byte, xorbyte|
		output <<	(byte ^ xorbyte)
	end

	return output
end

def averagestring(string)
	bytearray = string.bytes
	return (bytearray.inject(:+).to_f/bytearray.length)
end

def distancefromperfectaverage(average)
	#88.235 is the best average for an English string
	return (88.235 - average).abs
end

def distancefromaveragewordlength(average)
	#5.1 is the average word length usually
	return (5.1 - average).abs
end

def scorestring(string)
	if !string.empty? & string.force_encoding("UTF-8").ascii_only?
		score = 100

		#dock points for distance away from average English string
		average = averagestring(string)
		score -= (distancefromperfectaverage(average))

		wordlength = (string.length / string.split(" ").length.to_f)
		score -= (distancefromaveragewordlength(wordlength))

		return score
	end
	return 0
end

def hammingdistance(bytearrayone, bytearraytwo)
	if bytearrayone.length != bytearraytwo.length
		maxlength = [bytearrayone.length, bytearraytwo.length].max
		bytearrayone.fill(0, (bytearrayone.length)..(maxlength))
		bytearraytwo.fill(0, (bytearraytwo.length)..(maxlength))
	end

	#xor returns 1 if bits are different
	xorredbytes = fixedxor(bytearrayone, bytearraytwo)

	return xorredbytes.map!{ |byte| byte.to_s(2) }.join.count("1")
end

def findbestxor(bytearray)
	beststring = ""
	bestscore = 0

	(1..256).each do |i|
		xorredstring = bytearraytostring(singlebytexor(bytearray, i))

		score = scorestring(xorredstring)
		if score > bestscore
			beststring, bestscore = xorredstring, score
		end
	end

	return [beststring, bestscore]
end

def testoutput(output, validoutput)
	if output == validoutput
		puts("SUCCESS!")
	else
		puts("FAILURE!")
	end
end
