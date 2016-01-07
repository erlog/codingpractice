require_relative 'cryptopals'

def encodeprofile(emailaddress)
	dictionary = Hash.new()
	dictionary["email"] = emailaddress.gsub("=", "").gsub("&", "")
	dictionary["uid"] = rand(10..99)
	dictionary["role"] = "user"
	return dictionary
end 

def parsekequalsv(string)
	dictionary = Hash.new()
	items = string.split("&")
	items.each do |item|
		key, value = item.split("=")
		dictionary[key] = value
	end
	return dictionary
end

def encryptprofile(profilestring, key=randombytearray(16))
	encrypted = bytearraytostring(encryptAES128ECB(profilestring.bytes, key))
	return [encrypted, key]
end 

def decryptprofile(encryptedstring, key)
	decrypted = bytearraytostring(decryptAES128ECB(encryptedstring.bytes, key))
	return decrypted
end 

vulnstring = "iamahacker"
vulnstring += bytearraytostring(padbytearraywithPKCS7("admin".bytes, 16))
vulnstring += "@myhackerdomain.com"

profile = encodeprofile(vulnstring)
print profile; puts
profilestring = generatekequalsv(profile)
encryptedprofile, key = encryptprofile(profilestring)

encryptedblocks = encryptedprofile.bytes.each_slice(16).to_a

mungedblocks = []
mungedblocks << encryptedblocks[0]
mungedblocks << encryptedblocks[2]
mungedblocks << encryptedblocks[3]
mungedblocks << encryptedblocks[1]

mungedstring = bytearraytostring(mungedblocks.flatten)

decryptedprofile = decryptprofile(mungedstring, key)
print parsekequalsv(decryptedprofile)

