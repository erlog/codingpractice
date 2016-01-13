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

#send "p", "g", "publickey", over to bob
bob = diffiehellman(alice["p"], alice["g"])
bob = diffiehellmansessionkey(bob, alice["publickey"])

#send bob's public key to alice
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
#######################
alicemessage = "Hey there cutie!"
bobreply = "Hey! How are you?"
eavesdroppedlines = []

#start session
alice = diffiehellman(DiffieHellman_p, DiffieHellman_g)

#attempt to send "p", "g", "publickey", to bob, but caught by eve
eve = alice.dup
eve.delete("privatekey") #we were never sent this
eve["publickey"] = eve["p"] #eve switches out "publickey" for "p"

#eve sends the injected publickey to bob
bob = diffiehellman(eve["p"], eve["g"])
bob = diffiehellmansessionkey(bob, eve["publickey"])

#bob attempts to send public key to alice, but caught by eve
eve = bob.dup
eve.delete("privatekey") #we were never sent this
eve["publickey"] = eve["p"] #eve switches out "publickey" for "p"
eve["sessionkey"] = 0 #when p is used as public key the session key is 0

#eve sends the injected publickey to alice
alice = diffiehellmansessionkey(alice, eve["publickey"])

#send AES-CBC(msg, SHA1(s)[0:16], iv=random(16)) + iv
cipherfromalice = generatemessage(alice, alicemessage)

#alice attempts to send to bob, but caught by eve
eavesdroppedlines << decodemessage(eve, cipherfromalice)

#eve relays it to bob who then replies
messagefromalice = decodemessage(bob, cipherfromalice)
cipherfrombob = generatemessage(bob, bobreply)

#bob attempts to send to alice, but caught by eve
eavesdroppedlines << decodemessage(eve, cipherfrombob)

#eve relays it to alice
messagefrombob = decodemessage(alice, cipherfrombob)

print "Man-in-the-middle test: "
testoutput(eavesdroppedlines, [alicemessage, bobreply])
puts eavesdroppedlines
