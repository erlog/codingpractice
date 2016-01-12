require_relative 'cryptopals'

input = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
Key = bytearraytohexstring(randombytearray(rand(32)))

def addMACtomessage(message)
	return generateMAC(message) + message
end

def generateMAC(message)
	return bytearraytohexstring(sha1(Key + message))
end

def validateMAC(message)
	givenmac, message = message[0..39], message[40..-1]
	validmac = generateMAC(message)[0..39]
	return (givenmac == validmac) 
end

def generateSHA1padding(message)
	padding = [0x80]
	paddingamount = 55 - (message.length % 64) 
	padding += Array.new(paddingamount){0}

	messagelengthhex = (message.length*8).to_s(16).rjust(16, "0")
	messagelengthbytes = messagelengthhex.scan(/.{2}/).map!{|x| x = x.to_i(16)}
	padding += messagelengthbytes

	return padding
end

def deriveSHA1registers(hashhexstring)
	hashbytes = hexstringtobytearray(hashhexstring)
	registers = []
	hashbytes.each_slice(4).each do |slice|
		registers << bytearraytohexstring(slice).to_i(16)
	end
	return registers
end


validmessage = addMACtomessage(input)
validplaintext = validmessage[40..-1]
validregisters = deriveSHA1registers(validmessage[0..39])
vulnstring = ";admin=true"

keylength = 0 
while true
	puts ["Trying key of length: ", keylength].join
	dummykey = "0"*keylength 
	validpadding = bytearraytostring(generateSHA1padding(dummykey + validplaintext))

	fullvulnstring = dummykey + validplaintext + validpadding + vulnstring
	vulnpadding = bytearraytostring(generateSHA1padding(fullvulnstring))

	vulnhash = bytearraytohexstring(sha1(vulnstring + vulnpadding, 
									false, 
									validregisters.dup))

	output = vulnhash + validplaintext + validpadding + vulnstring

	validateMAC(output) ? (break) : (keylength += 1)
end

validoutput = addMACtomessage(input + validpadding + vulnstring)
testoutput(validoutput, output)
puts ["Admin access achieved: ", validateMAC(output)].join
puts ["Key length in bytes: ", keylength].join
