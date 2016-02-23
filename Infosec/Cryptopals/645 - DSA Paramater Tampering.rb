require_relative 'cryptopals.rb'

DSAp = "800000000000000089e1855218a0e7dac38136ffafa72eda7859f2171e25e65eac698c1702578b07dc2a1076da241c76c62d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebeac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc871a584471bb1".to_i(16)

DSAq = "f4f47f05794b256174bba6e9b396a7707e563c5b".to_i(16)

DSAg = DSAp+1

MessageOne = "Hello, world"
MessageTwo = "Goodbye, world"

#I didn't do g = 0 here because my signing implementation rejects outcomes
#   where r or s come out to zero

puts "DSA g: p + 1"
publickey, privatekey = generateDSAkeys()
puts "Public/Private Keys: " + [publickey, privatekey].to_s
signature = signDSA(MessageOne, privatekey)
puts "Signature('Hello, world'): " + signature.to_s
signature = signDSA(MessageTwo, privatekey)
puts "Signature('Goodbye, world'): " + signature.to_s
validsignature = verifyDSAsignature(MessageTwo, publickey, signature)
print "Real string verification: "; testoutput(true, validsignature)
fakevalidation = verifyDSAsignature("qwerty", publickey, signature)
print "Fake string verification: "; testoutput(true, validsignature)

