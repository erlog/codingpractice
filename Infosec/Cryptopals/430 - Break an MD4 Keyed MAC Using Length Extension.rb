require_relative 'cryptopals'

input = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
Key = bytearraytohexstring(randombytearray(16))

def addMACtomessage(message)
	return generateMAC(message) + message
end

def generateMAC(message)
	return bytearraytohexstring(md4(Key + message))
end

def validateMAC(message)
	givenmac, message = message[0..39], message[40..-1]
	validmac = generateMAC(message)[0..39]
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

def deriveSHA1registers(hashhexstring)
	hashbytes = hexstringtobytearray(hashhexstring)
	registers = []
	hashbytes.each_slice(4).each do |slice|
		registers << bytearraytohexstring(slice).to_i(16)
	end
	return registers
end
def out(object)
	print object.to_s; puts 
end

#validmessage = addMACtomessage(input)

out(bytearraytohexstring(md4("abc")))
out(generateMD4padding("abc"))
