require_relative "cryptopals"

input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736" 
validoutput = "Cooking MC's like a pound of bacon"

inputbytes = hexstringtobytearray(input)
beststring, bestscore = findbestxor(inputbytes)

puts beststring
testoutput(beststring, validoutput)
