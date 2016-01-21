require_relative "cryptopals"

Message = "Hey there!"

publickey, privatekey = generateRSAKeys()
cipher = encryptRSAstring(Message, publickey).to_i(16)

e, n = publickey[0],  publickey[1]
s = n + 2

#munge our ciphertext
alternatec = (modexp(s, e, n) * cipher) % n

#get it decrypted by the server
alternatepstring = decryptRSAstring(alternatec.to_s(16), privatekey)
alternatep = bytearraytohexstring(alternatepstring.bytes).to_i(16)

result = (alternatep * invmod(s, n)) % n
plaintext = hexstringtostring(result.to_s(16))

puts plaintext
testoutput(Message, plaintext)
