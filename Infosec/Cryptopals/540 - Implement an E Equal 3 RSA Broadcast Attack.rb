require_relative "cryptopals"

string = "Hey there!"

keys = generateRSAKeys()
ciphertext = encryptRSAstring(string, keys[0])
plaintext = decryptRSAstring(ciphertext, keys[1])

testoutput(string, plaintext)
