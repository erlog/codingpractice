require_relative 'cryptopals'

Key = randombytearray(16)
Nonce = rand(0xFFFFFFFF)

def oracle(userinput)
	prependstring = "comment1=cooking%20MCs;userdata="
	appendstring = ";comment2=%20like%20a%20pound%20of%20bacon"
	userinput.gsub!("=", '')
	userinput.gsub!(";", '')
	assembledstring = prependstring + userinput + appendstring
	
	return encryptAES128CTR(assembledstring.bytes, Key, Nonce)
end

def decryptoracle(inputbytes)
	return bytearraytostring(decryptAES128CTR(inputbytes, Key, Nonce))
end

def checkadmin(inputbytes)
	string = bytearraytostring(decryptAES128CTR(inputbytes, Key, Nonce))

	tuples = string.split(';')
	tuples.each do |tuple|
		key, value = tuple.split('=')
		if (key == "admin") & (value == "true")
			return true
		end
	end
	return false
end

xcipherbytes = oracle("x")
acipherbytes = oracle("a")
prependlength = 0
xcipherbytes.zip(acipherbytes).each do |x, a|
	if x != a
		break
	end
	prependlength += 1
end
puts ["Uncontrolled prepended string length: ", prependlength].join

vulnstring = "hello;admin=true"
dummystring = "A"*vulnstring.length

dummiedcipherbytes = oracle(dummystring)
targetcipherbytes = dummiedcipherbytes[prependlength..prependlength + vulnstring.length - 1]
vulnkeystream = fixedxor(targetcipherbytes, dummystring.bytes)
puts ["Keystream for vuln: ", vulnkeystream.to_s].join
encryptedvulnstring = fixedxor(vulnkeystream, vulnstring.bytes)

vulncipherbytes = dummiedcipherbytes[0..prependlength-1]
vulncipherbytes += encryptedvulnstring 
vulncipherbytes += dummiedcipherbytes[prependlength + vulnstring.length..-1]

print "Testing for admin access: "
testoutput(checkadmin(vulncipherbytes), true)
