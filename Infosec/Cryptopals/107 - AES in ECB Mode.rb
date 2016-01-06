require_relative "cryptopals"

input = open("107 - Input.txt").readlines.map!(&:strip).join
inputbytes = base64tobytearray(input)

keybytes = stringtobytearray("YELLOW SUBMARINE")

puts bytearraytostring(decryptAES128ECB(inputbytes, keybytes))
