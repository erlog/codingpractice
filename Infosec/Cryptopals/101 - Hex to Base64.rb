require "base64"
require_relative "cryptopals"

input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
inputbytes = hexstringtobytearray(input)
inputstring = bytearraytostring(inputbytes) 

puts inputstring

output = bytearraytobase64(inputbytes)
validoutput = Base64.strict_encode64(inputstring)

puts ["My algo: " + output].join 
puts ["Rb algo: " + validoutput].join

testoutput(output, validoutput)
