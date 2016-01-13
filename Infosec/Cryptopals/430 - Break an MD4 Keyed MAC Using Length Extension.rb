require_relative 'cryptopals'

input = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
Key = bytearraytohexstring(randombytearray(rand(32)))

def addMACtomessage(message)
	return generateMAC(message) + message
end

def generateMAC(message)
	return bytearraytohexstring(md4(Key + message))
end

def validateMAC(message)
	givenmac, message = message[0..31], message[32..-1]
	validmac = generateMAC(message)[0..31]
	return (givenmac == validmac) 
end

def generateMD4padding(message)
	padding = [0x80]
	paddingamount = 55 - (message.length % 64) 
	padding += Array.new(paddingamount){0}

	messagelengthhex = (message.length*8).to_s(16).rjust(16, "0")
	messagelengthbytes = messagelengthhex.scan(/.{2}/).reverse.map!{|x| x = x.to_i(16)}
	padding += messagelengthbytes

	return padding
end

def deriveMD4registers(hashhexstring)
	hashbytes = hexstringtobytearray(hashhexstring)
	registers = []
	hashbytes.each_slice(4).each do |slice|
		registers << bytearraytohexstring(slice.reverse).to_i(16)
	end
	return registers
end

def out(object)
	print object.to_s; puts 
end

validmessage = addMACtomessage(input)
validplaintext = validmessage[32..-1]
validregisters = deriveMD4registers(validmessage[0..31])
vulnstring = ";admin=true"

keylength = 0
while true
	puts ["Trying key of length: ", keylength].join
	dummykey = "A"* keylength

	validpaddingbytes = generateMD4padding(dummykey + validplaintext)
	validpadding = bytearraytostring(validpaddingbytes)
	
	fullvulnstring = dummykey + validplaintext + validpadding + vulnstring
	vulnpaddingbytes = generateMD4padding(fullvulnstring)
	vulnpadding = bytearraytostring(vulnpaddingbytes) 

	vulnhash = bytearraytohexstring(md4(vulnstring + vulnpadding, false, validregisters))
	output = vulnhash + validplaintext + validpadding + vulnstring

	validateMAC(output) ? (break) : (keylength += 1)
end

validoutput = addMACtomessage(input + validpadding + vulnstring)
testoutput(validoutput, output)
puts ["Admin access achieved: ", validateMAC(output)].join
puts ["Key length in bytes: ", keylength].join
