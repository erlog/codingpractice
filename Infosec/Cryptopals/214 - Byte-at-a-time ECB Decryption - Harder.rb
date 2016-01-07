require_relative 'cryptopals'

def oracle(userbytes)
	input = ["Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg",
	"aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq",
	"dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"].join
	inputbytes = padbytearraywithPKCS7(base64tobytearray(input), 16)
	randomprepad = [90, 254, 160, 42, 91, 163, 163, 42, 0, 130, 181, 173, 123]
	key = [4, 6, 224, 63, 104, 99, 114, 181, 32, 1, 113, 211, 95, 125, 242, 243]
	assembledinputbytes = randomprepad + userbytes + inputbytes
	return encryptAES128ECB(assembledinputbytes, key)
end


#Find the prepad length
testa = oracle("A".bytes)[0..15]
testb = oracle("AA".bytes)[0..15]
padlength = 2
while testa != testb
	testa = testb
	padlength += 1
	testb = oracle(("A"*padlength).bytes)[0..15]
end

prepadlength = padlength - 1
puts ["Prepad length: ", prepadlength].join

#Decrypt
numberofbytes = 256 
numberofbytes -= 1

foundbytes = []
(0..numberofbytes).to_a.reverse.each do |index|
	dictionary = Hash.new()
	padding = Array.new(index + prepadlength){65}

	(0..255).each do |testbyte|
		begin
			encryptedbytes = oracle(padding + foundbytes + [testbyte])
			encryptedbytes = encryptedbytes[16..numberofbytes+prepadlength]
			dictionary[encryptedbytes] = testbyte
		rescue NoMethodError
			exit	
		end
	end

	foundbyte = dictionary[oracle(padding)[16..numberofbytes+prepadlength]]
	foundbytes << foundbyte
	if foundbyte != nil then print foundbyte.chr end
end

