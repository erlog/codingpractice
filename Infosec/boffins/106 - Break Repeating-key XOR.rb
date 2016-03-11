require_relative "cryptopals"

lines = open("boffins1.txt").readlines.map!(&:strip)
#rotate ciphertext
chars = []
(0..49).each do |index|
    lines.each do |line|
        chars << line[index]
    end
end
inputbytes = chars.join.bytes

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
