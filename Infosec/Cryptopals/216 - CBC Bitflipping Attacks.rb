require_relative 'cryptopals'

def oracle(userinput)
	prependstring = "comment1=cooking%20MCs;userdata="
	appendstring = ";comment2=%20like%20a%20pound%20of%20bacon"
	userinput.gsub!("=", '')
	userinput.gsub!(";", '')
	assembledstring = prependstring + userinput + appendstring

	key = [102, 47, 205, 33, 234, 167, 99, 181, 28, 238, 103, 215, 103, 37, 226, 204]
	iv = [90, 209, 25, 95, 23, 69, 22, 168, 234, 255, 32, 50, 150, 243, 135, 67]

	return encryptAES128CBC(assembledstring.bytes, key, iv)
end

def decryptoracle(inputbytes)
	key = [102, 47, 205, 33, 234, 167, 99, 181, 28, 238, 103, 215, 103, 37, 226, 204]
	iv = [90, 209, 25, 95, 23, 69, 22, 168, 234, 255, 32, 50, 150, 243, 135, 67]
	return bytearraytostring(decryptAES128CBC(inputbytes, key, iv))
end

def checkadmin(inputbytes)
	key = [102, 47, 205, 33, 234, 167, 99, 181, 28, 238, 103, 215, 103, 37, 226, 204]
	iv = [90, 209, 25, 95, 23, 69, 22, 168, 234, 255, 32, 50, 150, 243, 135, 67]
	string = bytearraytostring(decryptAES128CBC(inputbytes, key, iv))
	puts string
	puts string[36]
	puts string[42]

	tuples = string.split(';')
	tuples.each do |tuple|
		key, value = tuple.split('=')
		if (key == "admin") & (value == "true")
			return true
		end
	end
	return false
end

oraclebytes = oracle("test*admin@true")
puts oraclebytes[36], oraclebytes[42]
oraclebytes[20] = 236
oraclebytes[26] = 91 
puts checkadmin(oraclebytes)
