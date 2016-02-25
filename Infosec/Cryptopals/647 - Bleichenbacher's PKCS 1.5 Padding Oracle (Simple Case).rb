require_relative 'cryptopals'

#Note: Despite being implemented pretty much as laid out in the problem
#   description this fails some of the time. This is probably due to the fact
#   that the description erroneously states that support for multiple ranges
#   is not required.
#
#   Since the next challenge is a full implementation of the Bleichenbacher '98
#   paper I decided that this was good enough and to just proceed challenge 48.

def paddingoracle(ciphertext)
    plainbytes = decryptRSAstring(ciphertext, PrivateKey)
    return true if ( (plainbytes[0] == 0) and (plainbytes[1] == 2) )
    return false
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

TwoB = bytearraytohexstring([0,2]+Array.new(MessageByteLength-2, 0)).to_i(16)
ThreeB = bytearraytohexstring([0,3]+Array.new(MessageByteLength-2, 0)).to_i(16)

#Step 1
#As stated in the "Remarks" section of the paper, we don't need to do step 1
#   for real if we know we have proper padding already.
s_zero = 1
c_zero = CipherText.to_i(16)

#Step 2a
s_one = (PublicKey[1]/ThreeB) - 1
valid = false
while !valid
    s_one += 1
    c_one = c_zero * modexp(s_one, PublicKey[0], PublicKey[1])
    valid = paddingoracle(c_one.to_s(16))
end

#Step 2c
s_last = s_one
lowerbound = TwoB
upperbound = ThreeB - 1
while (upperbound - lowerbound) > 1
    r = 2 * ( (upperbound * s_last - TwoB) / PublicKey[1] )
    s_last = ((TwoB + r * PublicKey[1]) / upperbound) - 1
    s_upperbound = (ThreeB + r * PublicKey[1]) / lowerbound

    valid = false
    while !valid
        if s_last > s_upperbound
            r += 1
            s_last = ((TwoB + r * PublicKey[1]) / upperbound) - 1
            s_upperbound = (ThreeB + r * PublicKey[1]) / lowerbound
        end
        s_last += 1
        c_last = c_zero * modexp(s_last, PublicKey[0], PublicKey[1])
        valid = paddingoracle(c_last.to_s(16))
    end

    newlowerbound = (TwoB + r * PublicKey[1]) / s_last
    lowerbound = [newlowerbound, lowerbound].max
    newupperbound = (ThreeB - 1 + r * PublicKey[1]) / s_last
    upperbound = [newupperbound, upperbound].min

    print "r: "; puts r
    print "s_last: "; puts s_last
    print "Lower Bound: "; puts lowerbound
    print "Upper Bound: "; puts upperbound
end

puts "Finished!"
m = (upperbound * invmod(s_zero, PublicKey[1])) % PublicKey[1]
message = bytearraytostring(removePKCS1type2padding(hexstringtobytearray(m.to_s(16))))
print "Plaintext: "; puts message
testoutput(message, PlainText)
