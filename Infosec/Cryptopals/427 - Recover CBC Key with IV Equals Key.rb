require_relative 'cryptopals'

Key = randombytearray(16)
IV = Key

def oracle(userinput)
	prependstring = "comment1=cooking%20MCs;userdata="
	appendstring = ";comment2=%20like%20a%20pound%20of%20bacon"
	userinput.gsub!("=", '')
	userinput.gsub!(";", '')
	assembledstring = prependstring + userinput + appendstring

	return encryptAES128CBC(assembledstring.bytes, Key, IV)
end

def decryptoracle(inputbytes)
	return bytearraytostring(decryptAES128CBC(inputbytes, Key, IV))
end

def verifyascii(inputbytes)
	inputbytes.each do |byte|
		puts byte.chr
		if (byte < 0x20) | (byte > 0x7E)
			return false
		end
	end
	return true
end

def checkadmin(inputbytes)
	string = bytearraytostring(decryptAES128CBC(inputbytes, Key, IV))
	if verifyascii(string.bytes) == false
		return [false, "Error: " + string]
	end
	tuples = string.split(';')
	tuples.each do |tuple|
		key, value = tuple.split('=')
		if (key == "admin") & (value == "true")
			return [true, ""]
		end
	end
	return [false, ""]
end

oraclebytes = oracle("test*admin@true")

check = checkadmin(oraclebytes)
puts check
