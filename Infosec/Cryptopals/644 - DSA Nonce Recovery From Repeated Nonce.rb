require_relative 'cryptopals.rb'

DSAp = "800000000000000089e1855218a0e7dac38136ffafa72eda7859f2171e25e65eac698c1702578b07dc2a1076da241c76c62d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebeac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc871a584471bb1".to_i(16)

DSAq = "f4f47f05794b256174bba6e9b396a7707e563c5b".to_i(16)

DSAg ="5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119458fef538b8fa4046c8db53039db620c094c9fa077ef389b5322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a0470f5b64c36b625a097f1651fe775323556fe00b3608c887892878480e99041be601a62166ca6894bdd41a7054ec89f756ba9fc95302291".to_i(16)

PublicKey = "2d026f4bf30195ede3a088da85e398ef869611d0f68f0713d51c9c1a3a26c95105d915e2d8cdf26d056b86b8a7b85519b1c23cc3ecdc6062650462e3063bd179c2a6581519f674a61f1d89a1fff27171ebc1b93d4dc57bceb7ae2430f98a6a4d83d8279ee65d71c1203d2c96d65ebbf7cce9d32971c3de5084cce04a2e147821".to_i(16)

PrivateKeySHA1 = "ca8f6f7c66fa362d40760d135b763eb8527d3d52"

def recoverk(one, two)
    m_one = bytearraytohexstring(sha1(one[0])).to_i(16)
    r_one, s_one = one[1]
    m_two = bytearraytohexstring(sha1(two[0])).to_i(16)
    r_two, s_two = two[1]

    m = (m_one - m_two) % DSAq
    s = (s_one - s_two) % DSAq
    k = (m * invmod(s, DSAq)) % DSAq
    return k
end

input = open("644 - Input.txt").readlines.map!(&:strip)
parsedinputs = []
while !input.empty?
    input.pop
    r = input.pop[3..-1].to_i
    s = input.pop[3..-1].to_i
    msg = input.pop[5..-1] + " "
    parsedinputs << [msg, [r, s]]
end

print "Verifying Input...  "
parsedinputs.each do |message, signature|
    valid = verifyDSAsignature(message, PublicKey, signature)
    if !valid
        puts "FAILED!"
        quit
    end
end
puts "SUCCESS!"

#Repeated nonces are denoted by identical r values, we only need one pair
repeatednoncepair = []
while repeatednoncepair.empty?
    message_one, signature_one = parsedinputs.pop
    parsedinputs.each do |message_two, signature_two|
        if signature_one[0] == signature_two[0]
            repeatednoncepair = [[message_one, signature_one],
                                    [message_two, signature_two]]
            break;
        end
    end
end

k = recoverk(repeatednoncepair[0], repeatednoncepair[1])

message, signature = repeatednoncepair[0]
x = convertDSAktox(message, k, signature)
puts "Recovered Private Key: " + x.to_s(16)

hash = bytearraytohexstring(sha1(x.to_s(16)))
testoutput(PrivateKeySHA1, hash)
