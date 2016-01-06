require_relative 'cryptopals'

input = "YELLOW SUBMARINE"
validoutput = [89, 69, 76, 76, 79, 87, 32, 83, 85, 66, 77, 65, 82, 73, 78, 69, 4, 4, 4, 4]

output = padbytearray(input.bytes, 20, 0x04)

print "Testing padding: "
testoutput(output, validoutput)
