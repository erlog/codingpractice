require_relative 'cryptopals'

input = open("210 - Input.txt").readlines.map!(&:strip).join
inputbytes = base64tobytearray(input) 
key = "YELLOW SUBMARINE"
keybytes = key.bytes

blocks = inputbytes.each_slice(16).to_a
iv = Array.new(16){ 0 }

outputbytes = decryptAES128CBC(inputbytes, keybytes, iv)
encryptedbytes = encryptAES128CBC(outputbytes, keybytes, iv)
outputbytes = decryptAES128CBC(encryptedbytes, keybytes, iv)

puts bytearraytostring(outputbytes)

puts "----"
print "Testing AES128-CBC: "
testoutput(inputbytes[0..32], encryptedbytes[0..32])

