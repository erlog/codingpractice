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
		if (byte < 0x20) | (byte > 0x7E) | (byte == nil)
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
			return [true, "Admin access achieved."]
		end
	end
	return [false, "No admin access."]
end

#get ciphertext back
cipherbytes = oracle("test")
cipherblocks = cipherbytes.each_slice(16).to_a

#modify output
vulnblocks = cipherblocks
vulnblocks[1] = Array.new(16){0} #this makes the xor over the next block a no-op 
vulnblocks[2] = vulnblocks[0]

check = checkadmin(vulnblocks.flatten)

if (check[0] == false) & (check[1][0..6] == "Error: ")
	errorbytes = check[1][7..-1].bytes
else
	puts "Failure! Did not receive plaintext in error."
	exit
end

errorblocks = errorbytes.each_slice(16).to_a

#the blocks we get back can be used to recover the key
#the first block is the normal decrypted output
#the second block is decryption from junk we injected
#the third block is the intermediate state of the first block
puts ["Intermediate state of first block: ", errorblocks[2].to_s].join

#by xorring the known plaintext with the intermediate state we retrieve
#the IV that was used to xor the first block
recoveredkey = fixedxor(errorblocks[0], errorblocks[2])

puts ["Recovered key: ", recoveredkey.to_s].join
testoutput(Key, recoveredkey)

