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
	client["serverpublickey"], client["salt"], client["u"] = 
		serverpublickey, salt, u

	#generate x = sha256(salt|password)
	x = sha256(client["salt"] + client["userpassword"]).to_i(16)

	#generate s = B**(a + ux) % n
	s = modexp(client["serverpublickey"], 
			(client["privatekey"] + client["u"] * x),
			client["N"])
	
	sK = sha256(s.to_s(16))
	client["sessionkey"] = generateHMACSHA256(sK, client["salt"])
end

#NORMAL LOGIN
#set agreed upon values
client = startSRPsession(DiffieHellman_p, 2, nil, useremail, userpassword)
server = startSRPsession(DiffieHellman_p, 2, nil, nil, userpassword)

initializesimplifiedSRPserver(server)
initializesimplifiedSRPclient(client)

generatesimplifiedSRPclientsessionkey(client, 
									server["publickey"],
									server["salt"],
									server["u"])
generatesimplifiedSRPserversessionkey(server, 
									client["useremail"], 
									client["publickey"])

print "Normal login test: "
testoutput(server["sessionkey"], client["sessionkey"])
		
#MITM PASSWORD GRAB
#set agreed upon values
client = startSRPsession(DiffieHellman_p, 2, nil, useremail, userpassword)

#generate public key
initializesimplifiedSRPclient(client)

#pose as the server and use arbitrary values for b, B, u, and salt.
eve = startSRPsession(DiffieHellman_p, 2, nil, nil, nil)
eve["userpassword"] = "" #don't know this yet
initializesimplifiedSRPserver(eve)

#send salt, public key, and u to client 
generatesimplifiedSRPclientsessionkey(client, 
								eve["publickey"], 
								eve["salt"], 
								eve["u"])

#client sends email, public key, and HMAC to eve
eve["useremail"], eve["clientpublickey"], eve["clientsessionkey"] =
	client["useremail"], client["publickey"], client["sessionkey"]

#run our dictionary attack against the HMAC posing as the server
commonpasswords.each do |password|
	x = sha256(eve["salt"] + password).to_i(16)

	eve["userpasswordhash"] = modexp(eve["g"], x, eve["N"])
	generatesimplifiedSRPserversessionkey(eve, eve["useremail"], eve["clientpublickey"])

	if eve["sessionkey"] == eve["clientsessionkey"]
		eve["userpassword"] = password
		break
	end  
end

print "Man in the middle dictionary attack: "
puts [eve["useremail"], "; ", eve["userpassword"]].join
testoutput(eve["userpassword"], userpassword)
