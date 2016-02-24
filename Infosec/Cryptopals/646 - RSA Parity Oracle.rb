require_relative 'cryptopals'

Input = "VGhhdCdzIHdoeSBJIGZvdW5kIHlvdSBkb24ndCBwbGF5IGFyb3VuZCB3aXRoIHRoZSBGdW5reSBDb2xkIE1lZGluYQ=="
PublicKey, PrivateKey = generateRSAKeys()
plaintext = bytearraytostring(base64tobytearray(Input))
CipherText = encryptRSAstring(plaintext, PublicKey)
plaintext = ""

def parityoracle(ciphertext)
    plaintext = decryptRSAstring(ciphertext, PrivateKey)
    return (plaintext.bytes[-1] % 2 == 0)
end

def multiplyciphertext(cipherinteger)
    return cipherinteger * modexp(2, PublicKey[0], PublicKey[1])
end

cipherinteger = CipherText.to_i(16)
lowerbound, upperbound = 0, PublicKey[1]

while (upperbound - lowerbound) > 1
    cipherinteger = multiplyciphertext(cipherinteger)

    if parityoracle(cipherinteger.to_s(16))
        upperbound -= ((upperbound - lowerbound) / 2)
    else
        lowerbound += ((upperbound - lowerbound) / 2)
    end

    puts hexstringtostring(upperbound.to_s(16))
end

puts "--------------"
puts "Decrypted Text:"
puts hexstringtostring(lowerbound.to_s(16))
puts hexstringtostring(upperbound.to_s(16))
