require_relative 'cryptopals'

Key = randombytearray(16)
Nonce = rand(0xFFFF)

inputbytes = base64tobytearray(open("425 - Input.txt").readlines.map!(&:strip).join)
plainbytes = decryptAES128ECB(inputbytes, "YELLOW SUBMARINE".bytes)

def editciphertext(cipherbytes, offset, newbytes)
	plainbytes = decryptAES128CTR(cipherbytes, Key, Nonce)
	beginning = plainbytes[0..offset-1]
	beginning = [] unless offset > 0
	ending = plainbytes[offset+newbytes.length..-1]
	newbytes = beginning + newbytes + ending
	return encryptAES128CTR(newbytes, Key, Nonce)
end

def testout(cipherbytes)
	plainbytes = decryptAES128CTR(cipherbytes, Key, Nonce)
	puts bytearraytostring(plainbytes[0..15])
end

cipherbytes = encryptAES128CTR(plainbytes, Key, Nonce)
dummybytes = ("A"*cipherbytes.length).bytes
dummiedcipherbytes = editciphertext(cipherbytes, 0, dummybytes)

puts plainbytes.length
puts dummiedcipherbytes.length

keystreambytes = fixedxor(dummiedcipherbytes, dummybytes)
decryptedbytes = fixedxor(keystreambytes, cipherbytes)

puts bytearraytostring(decryptedbytes)
testoutput(plainbytes, decryptedbytes)

