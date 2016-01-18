require_relative "cryptopals"

useremail="foo@bar.com"
userpassword="5e884898da28047151"

def startSRPsession(n, g, k, email, password)
	dict = Hash.new()
	dict["N"], dict["g"], dict["k"] = n, g, k
	dict["privatekey"] = rand(2**64)
	dict["useremail"], dict["userpassword"] = email, password
	return dict
end

def initializeSRPserver(server)
	#generate salt as a random integer
	server["salt"] = rand(2**64).to_s(16)

	#generate sha256(salt + password) and convert to integer x
	x = sha256(server["salt"] + server["userpassword"]).to_i(16)
	#generate v = g**x % N
	server["userpasswordhash"] = modexp(server["g"], x, server["N"])
	server.delete("userpassword")

	server["peruserpublickey"] = server["k"] * server["userpasswordhash"] +
		modexp(server["g"], server["privatekey"], server["N"])
end

def initializeSRPclient(client)
	client["publickey"] = modexp(client["g"], client["privatekey"], client["N"])
end

def generateSRPserversessionkey(server, useremail, clientpublickey)
	#receive email and public key(a la Diffie Hellman) to server
	server["useremail"], server["clientpublickey"] = useremail, clientpublickey 

	#generate sha256(clientpublickey + serverpublickey) as integer u
	uH = sha256(server["peruserpublickey"].to_s(16) +
		server["clientpublickey"].to_s(16))
	u = uH.to_i(16)

	#generate S = (A * v**u) ** b % N, K = sha256(S)
	s = modexp( ( server["clientpublickey"] * 
				modexp(server["userpasswordhash"],  u, server["N"] ) ), 
				server["privatekey"],
				server["N"])
	sK = sha256(s.to_s(16))

	#HMAC-SHA256(K, salt)
	server["HMAC"] = generateHMACSHA256(sK, server["salt"])
end

def generateSRPclientsessionkey(client, salt, serverpublickey)
	#receive salt and public key(kv + g**b % N)
	client["salt"], client["serverpublickey"] = salt, serverpublickey 

	#generate sha256(clientpublickey + serverpublickey) as integer u
	uH = sha256(client["serverpublickey"].to_s(16) + client["publickey"].to_s(16))
	u = uH.to_i(16)

	#generate sha256(salt + password) and convert to integer x
	x = sha256(client["salt"] + client["userpassword"]).to_i(16)

	#generate S = (B - k * g**x)**(a + u * x) % N, K = sha256(S)
	s = modexp( ( client["serverpublickey"] - client["k"] * 
				modexp(client["g"], x, client["N"]   )      ),
				( client["privatekey"] + u * x ), client["N"] )
	sK = sha256(s.to_s(16))

	#HMAC-SHA256(K, salt)
	client["HMAC"] = generateHMACSHA256(sK, client["salt"])
end

#agree on N=NIST Prime, g=2, k=3, useremail, and password
client = startSRPsession(DiffieHellman_p, 2, 3, useremail, userpassword)
server = startSRPsession(DiffieHellman_p, 2, 3, nil, userpassword)

#make user accounts, password hashes, public keys, etc. 
initializeSRPserver(server)
initializeSRPclient(client)

#client sends email + public key
generateSRPserversessionkey(server, client["useremail"], client["publickey"])

#server sends salt and the public key it's using for that user
generateSRPclientsessionkey(client, server["salt"], server["peruserpublickey"])

#client sends HMAC, server validates the HMAC from the client
if server["HMAC"] == client["HMAC"] then puts "OK" end

puts "Client Info: "
console(client.keys)
puts "Server Info: "
console(server.keys)
testoutput(server["HMAC"], client["HMAC"])
