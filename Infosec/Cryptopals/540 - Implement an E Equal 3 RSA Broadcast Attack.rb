require_relative "cryptopals"

Message = "Hey there!"

publickeyA = generateRSAKeys()[0]
ciphertextA = encryptRSAstring(Message, publickeyA).to_i(16)
publickeyB = generateRSAKeys()[0]
ciphertextB = encryptRSAstring(Message, publickeyB).to_i(16)
publickeyC = generateRSAKeys()[0]
ciphertextC = encryptRSAstring(Message, publickeyC).to_i(16)

msA = publickeyB[1] * publickeyC[1]
msB = publickeyA[1] * publickeyC[1]
msC = publickeyA[1] * publickeyB[1]

result = ciphertextA * msA * invmod(msA, publickeyA[1]) 
result += ciphertextB * msB * invmod(msB, publickeyB[1]) 
result += ciphertextC * msC * invmod(msC, publickeyC[1]) 
result = result % (publickeyA[1] * publickeyB[1] * publickeyC[1])
result = nthrootinteger(3, result)

plaintext = hexstringtostring(result.to_s(16))
puts plaintext
testoutput(Message, plaintext)
