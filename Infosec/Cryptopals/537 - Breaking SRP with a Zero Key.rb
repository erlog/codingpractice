require_relative "cryptopals"

useremail="foo@bar.com"
userpassword="5e884898da28047151"

#step 1, log in with password as normal
client = startSRPsession(DiffieHellman_p, 2, 3, useremail, userpassword)
server = startSRPsession(DiffieHellman_p, 2, 3, nil, userpassword)

#make public keys, user accounts, password hashes, etc. 
initializeSRPserver(server)
initializeSRPclient(client)

generateSRPserversessionkey(server, client["useremail"], client["publickey"])
generateSRPclientsessionkey(client, server["salt"], server["peruserpublickey"])

print "Normal login test: "
testoutput(server["HMAC"], client["HMAC"])

#step 2, break it with a zero key 
client = Hash.new()
client["useremail"] = useremail 
client["publickey"] = 0

#make public keys, user accounts, password hashes, etc. 
server = startSRPsession(DiffieHellman_p, 2, 3, nil, userpassword)
initializeSRPserver(server)

generateSRPserversessionkey(server, client["useremail"], client["publickey"])
client["HMAC"] = generateHMACSHA256(sha256("0"), server["salt"])

print "Zero key login test: "
testoutput(server["HMAC"], client["HMAC"])

#step 3, break it with N key 
client = Hash.new()
client["useremail"] = useremail 
client["publickey"] = DiffieHellman_p 

#make public keys, user accounts, password hashes, etc. 
server = startSRPsession(DiffieHellman_p, 2, 3, nil, userpassword)
initializeSRPserver(server)

generateSRPserversessionkey(server, client["useremail"], client["publickey"])
client["HMAC"] = generateHMACSHA256(sha256("0"), server["salt"])

print "N key login test: "
testoutput(server["HMAC"], client["HMAC"])

#step 4, break it with N*2 key 
client = Hash.new()
client["useremail"] = useremail 
client["publickey"] = DiffieHellman_p * 2 

#make public keys, user accounts, password hashes, etc. 
server = startSRPsession(DiffieHellman_p, 2, 3, nil, userpassword)
initializeSRPserver(server)

generateSRPserversessionkey(server, client["useremail"], client["publickey"])
client["HMAC"] = generateHMACSHA256(sha256("0"), server["salt"])

print "N*2 key login test: "
testoutput(server["HMAC"], client["HMAC"])

