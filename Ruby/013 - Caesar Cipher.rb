length = gets.strip.to_i
phrase = gets.strip
shift = gets.strip.to_i

for byte in phrase.bytes
	if (byte >= 65 and byte <= 90)
		byte += shift
		while byte > 90
			byte -= 26
		end
	elsif (byte >=97 and byte <= 122)
		byte += shift
		while byte > 122
			byte -= 26
		end
	end
	print byte.chr
end

