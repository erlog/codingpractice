require_relative 'cryptopals'

inputlines = open("319 - Input.txt").readlines.map!(&:strip)
decryptiontestinputlines = open("319 - Decrypted.txt").readlines.map!(&:strip)

keybytes = [16, 96, 46, 160, 101, 131, 161, 81, 174, 12, 85, 64, 98, 93, 126, 75]
nonce = 0

ciphertexts = []
inputlines.each do |line|
	ciphertexts << encryptAES128CTR(base64tobytearray(line), keybytes, nonce)
end

testdecryptionciphertexts = []
decryptiontestinputlines.each do |line|
	testdecryptionciphertexts << encryptAES128CTR(line.bytes, keybytes, nonce)
end

testoutput(ciphertexts, testdecryptionciphertexts)

counter = 1
ciphertexts.zip(testdecryptionciphertexts).each do |cipherbytes, testbytes|
	print [counter, " --- "].join
	puts decryptiontestinputlines[counter-1]
	counter += 1
	print cipherbytes[0..15]
	puts
	print testbytes[0..15]
	puts
	exit
end

