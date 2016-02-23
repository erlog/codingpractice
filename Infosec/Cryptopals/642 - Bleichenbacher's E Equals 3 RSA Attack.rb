require_relative "cryptopals"

Message = "hi dad"
FakeMessage = "hi mom"

def padbytearraywithPKCS1dot5SHA1(bytearray, bytelength)
	headerbytes = hexstringtobytearray("0001")
    derbytes = hexstringtobytearray("003021300906052b0e03021a05000414")
    paddinglength = bytelength - headerbytes.length - derbytes.length - bytearray.length
    paddingbytes = Array.new(paddinglength, 255)
    return headerbytes + paddingbytes + derbytes + bytearray
end

def unsecureverify(message, signature, publickey)
    plainsignature = cryptRSAraw(signature.to_i(16), publickey).to_s(16)
    signaturebytes = hexstringtobytearray(plainsignature)

    #parse padding
    return false unless signaturebytes[0] == 1
    signaturebytes = signaturebytes[1..-1]
    while signaturebytes[0] == 255
        signaturebytes = signaturebytes[1..-1]
    end
    signaturebytes = signaturebytes[16..-1] #strip ASN.1 DER
    hashbytes = signaturebytes[0..19] #throw away trailing garbage

    hash = bytearraytohexstring(hashbytes)
    puts "Hash in sent signature: " + hash
    return (hash == sha1string(message))
end

publickey, privatekey = generateRSAKeys()
hash = sha1string(Message)
puts "Message Hash:      " + hash
paddedbytes = padbytearraywithPKCS1dot5SHA1(hexstringtobytearray(hash), 128) #RSA1024
paddedstring = bytearraytohexstring(paddedbytes)
signature = cryptRSAraw(paddedstring.to_i(16), privatekey).to_s(16)
puts "Signature: " + signature
puts "Real Message Verifies: " + unsecureverify(Message, signature, publickey).to_s
puts "----"

hash = sha1string(FakeMessage)
fakepaddedbytes = padbytearraywithPKCS1dot5SHA1(hexstringtobytearray(hash), 39)
fakepaddedbytes += Array.new(128-fakepaddedbytes.length, 255)
fakepaddedstring = bytearraytohexstring(fakepaddedbytes)
fakeplainint = fakepaddedstring.to_i(16)
fakesignature = nthrootinteger(3, fakepaddedstring.to_i(16))
puts "Fake Padded String: " + fakepaddedstring
puts "Fake Signature: " + fakesignature.to_s
puts "Fake Message Hash:      " + hash
puts "Fake Message Verifies: " + unsecureverify(FakeMessage, fakesignature.to_s(16), publickey).to_s


