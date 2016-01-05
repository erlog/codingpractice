require_relative "cryptopals"

inputstring = "1c0111001f010100061a024b53535009181c"
inputxor = "686974207468652062756c6c277320657965"

inputbytes = hexstringtobytearray(inputstring)
xorbytes = hexstringtobytearray(inputxor)

puts ["Input A: ", inputstring].join
puts ["Input B: ", inputxor].join

output = bytearraytohexstring(fixedxor(inputbytes, xorbytes))
puts ["Output: ", output].join

validoutput = "746865206b696420646f6e277420706c6179"

testoutput(output, validoutput)
