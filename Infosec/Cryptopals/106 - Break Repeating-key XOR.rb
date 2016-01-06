require_relative "cryptopals"

input = open("106 - Input.txt").readlines.map!(&:strip).join
inputbytes = base64tobytearray(input)

#Test our hammingdistance algo
inputa = "this is a test"
inputb = "wokka wokka!!!"
validoutput = 37

output = hammingdistance(stringtobytearray(inputa), stringtobytearray(inputb))

print "Testing hammingdistance: "
testoutput(output, validoutput)

keylength = findrepeatingkeyxorkeylength(inputbytes)

#create our caesar cipher strips
transposedbytes = transposebytearray(inputbytes, keylength)

#get our key
key = findrepeatingkeyxorkey(transposedbytes)
keystring = bytearraytostring(key)

puts ["Key: ", keystring].join 

#decrypt
puts "-----"
puts bytearraytostring(repeatingkeyxor(inputbytes, key))
puts "-----"

validoutput = "Terminator X: Bring the noise"
testoutput(keystring, validoutput)
