require_relative "cryptopals"

Message = "hi mom"

def padbytearraywithPKCS1dot5(bytearray, bytelength, hashfunction)
	padding = [0, 1]
	
end

publickey, privatekey = generateRSAKeys()

hashbytes = hexstringtobytearray(sha256(Message))
blocklength = publickey[1].to_s(2)/8

paddebytes = padbytearraywithPKCS1dot5(hashbytes, 64)

print paddedbytes


