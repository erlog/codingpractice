require_relative 'cryptopals'

input = "L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=="
cipherbytes = base64tobytearray(input)
keybytes = "YELLOW SUBMARINE".bytes
nonce = 0

decipherbytes = decryptAES128CTR(cipherbytes, keybytes, nonce)
output = bytearraytostring(decipherbytes)
puts output
testoutput(output, "Yo, VIP Let's kick it Ice, Ice, baby Ice, Ice, baby ")
