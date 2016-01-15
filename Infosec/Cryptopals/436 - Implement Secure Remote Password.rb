require_relative "cryptopals"

useremail="foo@bar.com"
userpassword="5e884898da28047151"

def startsession(n, g, k, email, password)
	dict = Hash.new()
	dict["N"], dict["g"], dict["k"] = n, g, k
	dict["privatekey"] = rand(2**64)
	dict["useremail"], dict["userpassword"] = email, password
	return dict
end

def sha256stringtointeger(string)
	return string.to_i(16)
	integer = string.to_i(16)	
	integer = integer % (2**15-1)
	return integer 
end

#agree on N=NIST Prime, g=2, k=3, useremail, and password
client = startsession(DiffieHellman_p, 2, 3, useremail, userpassword)
server = startsession(DiffieHellman_p, 2, 3, nil, userpassword)

#SERVER
#generate salt as a random integer
server["salt"] = rand(2**64).to_s(16)
#generate sha256(salt + password) and convert to integer x
x = sha256stringtointeger(sha256(server["salt"] + server["userpassword"]))
#generate v = g**x % N
server["v"] = modexp(server["g"], x, server["N"])
#keep everything but x
x = nil

#CLIENT
#send email and public key(a la Diffie Hellman) to server
client["publickey"] = modexp(client["g"], client["privatekey"], client["N"])
server["useremail"] = client["useremail"]
server["partnerpublickey"] = client["publickey"]

#SERVER
#send salt and public key(kv + g**b % N)
server["publickey"] = server["k"] * server["v"]
server["publickey"] += modexp(server["g"], server["privatekey"], server["N"])
client["salt"] = server["salt"]
client["partnerpublickey"] = server["publickey"]

#CLIENT & SERVER
#generate sha256(clientpublickey + serverpublickey) as integer u
uH = sha256(server["publickey"].to_s(16) + server["partnerpublickey"].to_s(16))
server["u"] = sha256stringtointeger(uH)
uH = sha256(client["partnerpublickey"].to_s(16) + client["publickey"].to_s(16))
client["u"] = sha256stringtointeger(uH)
uH = nil #throw this away so we don't get confused

#CLIENT
#generate sha256(salt + password) and convert to integer x
x = sha256stringtointeger(sha256(client["salt"] + client["userpassword"]))

#generate S = (B - k * g**x)**(a + u * x) % N, K = sha256(S)
s = modexp( (client["partnerpublickey"] - client["k"] * client["g"] ** x),
			(client["privatekey"] + client["u"] * x),
			client["N"])
client["K"] = sha256(s.to_s(16))

#SERVER
#generate S = (A * v**u) ** b % N, K = sha256(S)
s = modexp( (server["partnerpublickey"] * server["v"] ** server["u"]),
			server["privatekey"],
			server["N"])
server["K"] = sha256(s.to_s(16))

#CLIENT
#send HMAC-SHA256(K, salt)
client["HMAC"] = generateHMACSHA256(client["K"], client["salt"])
server["clientHMAC"] = client["HMAC"]

#SERVER
#validate the HMAC from the client
server["HMAC"] = generateHMACSHA256(server["K"], server["salt"])
if server["HMAC"] == client["HMAC"] then puts "OK" end

console(client["HMAC"])
console(server["HMAC"])
testoutput(server["HMAC"], server["clientHMAC"])
