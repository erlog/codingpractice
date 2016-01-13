require_relative 'cryptopals'

#I know this exercise asks you to spool up some sort of simple webserver.
#I didn't really see the point of this since no other challenge requires it.
#So I've just mocked it up the same way the other challenges ask you to.

URL = "http://localhost:9000/test?"

#SERVER FUNCTIONS
#################
Key = bytearraytostring(randombytearray(64))

def insecurecompare(a, b)
	if (a.empty?) | (b.empty?) then return false end

	a.bytes.zip(b.bytes) do |bytea, byteb|
		return false if bytea != byteb
		sleep(0.05)
	end

	return false if a.length != b.length
	return true
end

def receiverequest(urlstring)
	requestdata = urlstring[27..-1].split("&")
	filename, signature = requestdata[0][5..-1], requestdata[1][10..-1]

	validHMAC = generateHMACSHA1(filename, Key)

	insecurecompare(signature, validHMAC) ? (return 200) : (return 500)
end

#CLIENT FUNCTIONS
#################
def buildrequest(filename, signature)
	requeststring = URL + "file=" + filename
	requeststring += "&" + "signature=" + signature
	return requeststring
end

filename = "foo"
signaturechars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
				"a", "b", "c", "d", "e", "f"]

signature = ""

while true 
	request = buildrequest(filename, signature)
	response = receiverequest(request)
	break if response == 200

	maxresponsetime, maxresponsechar = 0, ""

	signaturechars.each do |char|
		request = buildrequest(filename, signature + char)
		prerequesttime = Time.now
		response = receiverequest(request)
		responsetime = Time.now - prerequesttime
		if responsetime > maxresponsetime
			maxresponsetime = responsetime
			maxresponsechar = char
		end
	end

	signature += maxresponsechar
	print maxresponsechar
end
puts

output = buildrequest(filename, signature)
puts output
validrequest = buildrequest("foo", generateHMACSHA1("foo", Key))
puts validrequest
testoutput(output, validrequest)
