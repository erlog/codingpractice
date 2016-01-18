require_relative "cryptopals"

commonpasswords = ["123456", "12345", "123456789", "Password", "iloveyou",
				"princess", "cryptopals", "1234567", "12345678", "abc123",
				"Nicole", "Daniel", "babygirl", "monkey", "Jessica",
				"Lovely", "michael", "Ashley", "654321", "QWERTY"]

useremail = "foo@bar.com"
userpassword = commonpasswords.sample

def initializesimplifiedSRPserver(server)
	server["salt"] = rand(2**64).to_s(16)
	#generate x = sha256(salt|password)
	x = sha256(server["salt"] + server["userpassword"]).to_i(16)
	server.delete("userpassword")
	#generate v = g**x % N
	server["userpasswordhash"] = modexp(server["g"], x, server["N"])
	#generate B = g**b % N
	server["publickey"] = modexp(server["g"], server["privatekey"], server["N"])
	#generate u = 128 bit random number
	server["u"] = rand(2**128)
end

def initializesimplifiedSRPclient(client)
	client["publickey"] = modexp(client["g"], client["privatekey"], client["N"])
end

def generatesimplifiedSRPserversessionkey(server, useremail, clientpublickey)
	server["useremail"], server["clientpublickey"] = useremail, clientpublickey

	#generate s = (A * v ** u)**b % n
	s = modexp( server["clientpublickey"] * 
				modexp(server["userpasswordhash"], server["u"], server["N"] ),
				server["privatekey"],
				server["N"])
	sK = sha256(s.to_s(16))
	server["sessionkey"] = generateHMACSHA256(sK, server["salt"])
end

def generatesimplifiedSRPclientsessionkey(client, serverpublickey, salt, u)
	client["serverpublickey"], client["salt"], client["u"] = serverpublickey, salt, u

	#generate x = sha256(salt|password)
	x = sha256(client["salt"] + client["userpassword"]).to_i(16)
	#generate s = B**(a + ux) % n
	s = modexp(client["serverpublickey"], 
			(client["privatekey"] + client["u"] * x),
			client["N"])
	
	sK = sha256(s.to_s(16))
	client["sessionkey"] = generateHMACSHA256(sK, client["salt"])
end
		
#MITM PASSWORD GRAB
#set agreed upon values
client = startSRPsession(DiffieHellman_p, 2, nil, useremail, userpassword)
eve = Hash.new()
eve["N"], eveserver["g"] = DiffieHellman_p, 2

#generate public keys, password hashes, etc.
initializesimplifiedSRPclient(client)

#pose as the server and use arbitrary values for b, B, u, and salt.
eve["privatekey"] = 0
eve["publickey"] = 2 
eve["u"] = 1
eve["salt"] = ""

#send salt, B = g**b % n, u = 128 bit random number to client
generatesimplifiedSRPclientsessionkey(client, 
								eve["publickey"], 
								eve["salt"], 
								eve["u"])


clientHMAC = client["sessionkey"]
