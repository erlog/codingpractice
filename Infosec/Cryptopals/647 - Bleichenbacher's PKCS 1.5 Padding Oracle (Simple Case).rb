require_relative 'cryptopals'

def paddingoracle(ciphertext)
    plainbytes = decryptRSAstring(ciphertext, PrivateKey)
    return true if ( (plainbytes[0] == 0) and (plainbytes[1] == 2) )
    return false
end

def padbytearraywithPKCS1type2(bytearray, length)
    header = [0, 2]
    bytearray = [0] + bytearray
    paddinglength = length - bytearray.length - header.length
    padding = randombytearray(paddinglength)
    return header + padding + bytearray
end

PlainText = "kick it, CC"
KeyBitLength = 256
MessageByteLength = KeyBitLength/8
PublicKey, PrivateKey = generateRSAKeys(KeyBitLength)
print "Public Key: "; puts PublicKey.to_s

#Make ciphertext and test our oracle
paddedplainbytes = padbytearraywithPKCS1type2(PlainText.bytes, KeyBitLength/8)
paddedplaininteger = bytearraytohexstring(paddedplainbytes).to_i(16)
print "Plaintext: "; puts paddedplaininteger

CipherText = cryptRSAraw(paddedplaininteger, PublicKey).to_s(16)
valid = paddingoracle(CipherText)
print "Confirming Padding Oracle Works: "; testoutput(true, valid)

lowerboundbytes = [0,2]+Array.new(MessageByteLength-2, 0)
upperboundbytes = [0,3]+Array.new(MessageByteLength-2, 0)
twoB = bytearraytohexstring(lowerboundbytes).to_i(16)
threeB = bytearraytohexstring(upperboundbytes).to_i(16)

lowerbound = twoB
upperbound = threeB - 1

print "Lower Bound: "; puts lowerbound
print "Upper Bound: "; puts upperbound


#Step 1
s_zero = 1
c_zero = CipherText.to_i(16)

#Step 2a
s_one = (PublicKey[1]/threeB) - 1
valid = false
while !valid
    s_one += 1
    c_one = c_zero * modexp(s_one, PublicKey[0], PublicKey[1])
    valid = paddingoracle(c_one.to_s(16))
end


s_last = s_one
while (upperbound - lowerbound) > 1
    #Step 2c
    r = 2 * ( (upperbound * s_last - twoB) / PublicKey[1] )
    s_last = ((twoB + r * PublicKey[1]) / upperbound) - 1
    s_upperbound = (threeB + r * PublicKey[1]) / lowerbound

    valid = false
    while !valid
        if s_last > s_upperbound
            r += 1
            s_last = ((twoB + r * PublicKey[1]) / upperbound) - 1
            s_upperbound = (threeB + r * PublicKey[1]) / lowerbound
        end
        s_last += 1
        c_last = c_zero * modexp(s_last, PublicKey[0], PublicKey[1])
        valid = paddingoracle(c_last.to_s(16))
    end

    newlowerbound = (twoB + r * PublicKey[1]) / s_last
    lowerbound = [newlowerbound, lowerbound].max
    newupperbound = (threeB - 1 + r * PublicKey[1]) / s_last
    upperbound = [newupperbound, upperbound].min

    print "r: "; puts r
    print "s_last: "; puts s_last
    print "Lower Bound: "; puts lowerbound
    print "Upper Bound: "; puts upperbound
end

puts "Finished!"
m = (upperbound * invmod(s_zero, PublicKey[1])) % PublicKey[1]
print "Plaintext: "; puts hexstringtostring(m.to_s(16))
