require_relative 'cryptopals'

def generatemessage(sessiondict, message)
	#the owner of sessiondict is sending the message
	#send AES-CBC(msg, SHA1(s)[0:16], iv=random(16)) + iv
	keybytes = sha1(sessiondict["sessionkey"].to_s(16))[0..15]
	ivbytes = randombytearray(16)
	cipherbytes = encryptAES128CBC(message.bytes, keybytes, ivbytes)
	return bytearraytohexstring(cipherbytes) + bytearraytohexstring(ivbytes) 
end

def decodemessage(sessiondict, ciphertext)
	#the owner of sessiondict is receiving the message
	keybytes = sha1(sessiondict["sessionkey"].to_s(16))[0..15]
	cipherbytes = hexstringtobytearray(ciphertext)
	ivbytes = cipherbytes[-16..-1]
	cipherbytes = cipherbytes[0..-17]
	messagebytes = decryptAES128CBC(cipherbytes, keybytes, ivbytes)
	return bytearraytostring(messagebytes)
end


#DIRECT COMMUNICATION TEST
##########################
alicemessage = "Hey there cutie!"

#start session
alice = diffiehellman(DiffieHellman_p, DiffieHellman_g)

#send "p", "g", over to bob
bob = diffiehellman(alice["p"], alice["g"])

#bob sends ACK, alice sends her publickey
bob = diffiehellmansessionkey(bob, alice["publickey"])

#bob sends public key to alice
alice = diffiehellmansessionkey(alice, bob["publickey"])

#send AES-CBC(msg, SHA1(s)[0:16], iv=random(16)) + iv
cipherfromalice = generatemessage(alice, alicemessage)

#bob decodes alice's message and sends it back to her
messagefromalice = decodemessage(bob, cipherfromalice)
cipherfrombob = generatemessage(bob, messagefromalice)

#alice decodes the message
messagefrombob = decodemessage(alice, cipherfrombob)

print "Direct communication: "
testoutput(alicemessage, messagefrombob)


#MAN-IN-THE-MIDDLE TEST
#replace "g" with 1
#######################
alicemessage = "Hey there cutie!"
bobreply = "Hey! How are you?"
eavesdroppedlines = []
evealice = Hash.new()
evebob = Hash.new()

#start session
alice = diffiehellman(DiffieHellman_p, DiffieHellman_g)

#attempt to send "p", "g", to bob, but caught by eve
evealice = Hash.new()
evealice["p"], evealice["g"] = alice["p"], alice["g"] #eve copies alice's p/g 
evebob["p"], evebob["g"] = alice["p"], 1 #eve switches out "g" for "1"

#eve sends bogus g to bob 
bob = diffiehellman(evebob["p"], evebob["g"])

#bob sends ACK, eve relays 
#alice sends her publickey, eve forges session key and relays 
evealice["publickey"] = alice["publickey"]
bob = diffiehellmansessionkey(bob, evealice["publickey"])

#bob sends his public key, eve forges session key and relays
evebob["publickey"] = bob["publickey"]
evealice["sessionkey"] = 1
alice = diffiehellmansessionkey(alice, evebob["publickey"])

print "evealice: "; console(evealice.keys)
print "evebob: "; console(evebob.keys)
console(alice)
console(bob)
exit

#send AES-CBC(msg, SHA1(s)[0:16], iv=random(16)) + iv
cipherfromalice = generatemessage(alice, alicemessage)

#alice attempts to send to bob, but caught by eve
eavesdroppedlines << decodemessage(evebob, cipherfromalice)

#eve relays it to bob who then replies
messagefromalice = decodemessage(bob, cipherfromalice)
cipherfrombob = generatemessage(bob, bobreply)

#bob attempts to send to alice, but caught by eve
eavesdroppedlines << decodemessage(evealice, cipherfrombob)

#eve relays it to alice
messagefrombob = decodemessage(alice, cipherfrombob)

print "Man-in-the-middle test: "
testoutput(eavesdroppedlines, [alicemessage, bobreply])
puts eavesdroppedlines
