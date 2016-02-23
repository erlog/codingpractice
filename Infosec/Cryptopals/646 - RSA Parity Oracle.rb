require_relative 'cryptopals'

Input = "VGhhdCdzIHdoeSBJIGZvdW5kIHlvdSBkb24ndCBwbGF5IGFyb3VuZCB3aXRoIHRoZSBGdW5reSBDb2xkIE1lZGluYQ=="

PublicKey, PrivateKey = generateRSAKeys()
plaintext = bytearraytostring(base64tobytearray(Input))
puts plaintext
CipherText = cryptRSAstring(plaintext, PublicKey)
plaintext = ""

def parityoracle(ciphertext)
    plaintext = cryptRSAstring(CipherText, PrivateKey)
    return (plaintext.bytes[-1] % 2 == 0)
end

def halfciphertext(ciphertext)
    return ciphertext * modexp(0.5, PublicKey[0], PublicKey[1])
end

iseven = parityoracle(CipherText)
ciphertext = bytearraytohexstring(CipherText.bytes).to_i(16)
puts ciphertext
bitstring = ""
while ciphertext > 100
    if iseven
        bitstring = "0" + bitstring
    else
        bitstring = "1" + bitstring
    end
    puts hexstringtostring(bitstring.to_i(2).to_s(16))

    ciphertext = halfciphertext(ciphertext)
    iseven = parityoracle(
end
