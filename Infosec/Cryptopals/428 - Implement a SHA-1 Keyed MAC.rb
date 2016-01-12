require_relative 'cryptopals'

Key = bytearraytohexstring(randombytearray(16))
def addMACtomessage(message)
	return generateMAC(message) + message
end

def generateMAC(message)
	return bytearraytohexstring(sha1(Key + message))
end

def validateMAC(message)
	givenmac = message[0..39]
	message = message[40..-1]
	validmac = generateMAC(message)[0..39]
	return (givenmac == validmac) 
end

validmessage = addMACtomessage("this is a test message")
puts ["Valid message: ", validmessage].join
tamperedmessage = validmessage[0..39] + "this is a tamperedmessage"
puts ["Tampered message: ", tamperedmessage].join

outputs = []
outputs << validateMAC(validmessage)
puts ["Valid message is valid: ", outputs[-1]].join
outputs << validateMAC(tamperedmessage)
puts ["Tampered message is valid: ", outputs[-1]].join

testoutput([true, false], outputs)
