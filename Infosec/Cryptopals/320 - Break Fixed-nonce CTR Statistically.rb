require_relative 'cryptopals'

inputlines = open("319 - Input.txt").readlines.map!(&:strip)

keybytes = [225, 140, 188, 130, 216, 120, 168, 68, 99, 53, 113, 248, 199, 145, 219, 59] 
nonce = 0

ciphertexts = []
inputlines.each do |line|
	ciphertexts << encryptAES128CTR(base64tobytearray(line), keybytes, nonce)
end

shortestlength = ciphertexts.map(&:length).sort[0]

truncatedciphertexts = []
ciphertexts.each do |cipherbytes|
	truncatedciphertexts << cipherbytes[0..shortestlength-1]
end

transposed = transposebytearray(truncatedciphertexts.flatten, shortestlength)
possiblekey = findrepeatingkeyxorkey(transposed)
possiblekey[0] = 166 #first byte was nonstandard so I had to use some algebra 

truncatedciphertexts.each do |cipherbytes|
	output = bytearraytostring(fixedxor(cipherbytes, possiblekey))
	puts output
end

