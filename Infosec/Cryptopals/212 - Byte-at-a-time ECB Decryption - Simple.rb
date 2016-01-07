require_relative 'cryptopals'

def oracle(prepadding)
	input = ["Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg",
	"aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq",
	"dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"].join
	inputbytes = padbytearraywithPKCS7(base64tobytearray(input), 16)
	key = [4, 6, 224, 63, 104, 99, 114, 181, 32, 1, 113, 211, 95, 125, 242, 243]
	assembledinputbytes = padbytearraywithPKCS7(prepadding + inputbytes, 16)
	return encryptAES128ECB(assembledinputbytes, key)
end

keylength = 1
encryptedblocks = oracle("A".bytes)
while encryptedblocks[0] != encryptedblocks[1]
	keylength += 1
	testbytes = ("A"*keylength*2).bytes
	encryptedblocks = oracle(testbytes).each_slice(keylength).to_a
end

puts ["Key length: ", keylength.to_s].join	


testinput = "A"*128
encryptedtestblocks = oracle(testinput.bytes).each_slice(16).to_a
if encryptedtestblocks[2] == encryptedtestblocks[3]
	puts "ECB Detected!"
else
	puts "ECB Not Detected!"
	return 0
end

numberofbytes = 256 
numberofbytes -= 1 
foundbytes = []

(0..numberofbytes).to_a.reverse.each do |index|
	dictionary = Hash.new()
	padding = Array.new(index){65}

	(0..255).each do |testbyte|
		begin
			encryptedbytes = oracle(padding + foundbytes + [testbyte])[0..numberofbytes]
			dictionary[encryptedbytes] = testbyte
		rescue NoMethodError
			exit	
		end
	end

	foundbyte = dictionary[oracle(padding)[0..numberofbytes]]
	foundbytes << foundbyte
	if foundbyte != nil then print foundbyte.chr end
end

