require_relative 'cryptopals.rb'

DSAp = "800000000000000089e1855218a0e7dac38136ffafa72eda7859f2171e25e65eac698c1702578b07dc2a1076da241c76c62d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebeac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc871a584471bb1".to_i(16)

DSAq = "f4f47f05794b256174bba6e9b396a7707e563c5b".to_i(16)

DSAg ="5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119458fef538b8fa4046c8db53039db620c094c9fa077ef389b5322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a0470f5b64c36b625a097f1651fe775323556fe00b3608c887892878480e99041be601a62166ca6894bdd41a7054ec89f756ba9fc95302291".to_i(16)

PublicKey = "84ad4719d044495496a3201c8ff484feb45b962e7302e56a392aee4abab3e4bdebf2955b4736012f21a08084056b19bcd7fee56048e004e44984e2f411788efdc837a0d2e5abb7b555039fd243ac01f0fb2ed1dec568280ce678e931868d23eb095fde9d3779191b8c0299d6e07bbb283e6633451e535c45513b2d33c99ea17".to_i(16)

Message = "For those that envy a MC it can be hazardous to your health\nSo be friendly, a matter of life and death, just like a etch-a-sketch\n"

Signature = [548099063082341131477253921760299949438196259240,
                857042759984254168557880549501802188789837994940]

PrivateKeySHA1 = "0954edd5e0afe5542a4adf012611a91912a3ec16"

#Test Implementations
publickey, privatekey = generateDSAkeys()
signature = signDSA(Message, privatekey)
k = signature.pop
validsignature = verifyDSAsignature(Message, publickey, signature)
print "Real verification: "; testoutput(true, validsignature)
recoveredkey = convertDSAktox(Message, k, signature)
print "Key Recovered: "; testoutput(privatekey, recoveredkey)

#Do the problem
puts "-----"
validsignature = verifyDSAsignature(Message, PublicKey, Signature)
print "Verify Signature: "; testoutput(true, validsignature)
puts "Breaking Private Key..."
x = 0
(1..2**16).each do |k|
    x = convertDSAktox(Message, k, Signature)
    y = generateDSApublickey(x)
    break if y == PublicKey
end
puts "Private Key: " + x.to_s(16)
hash = bytearraytohexstring(sha1(x.to_s(16)))
testoutput(PrivateKeySHA1, hash)
