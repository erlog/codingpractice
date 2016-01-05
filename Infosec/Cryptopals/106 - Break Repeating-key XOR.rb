require_relative "cryptopals"

input = open("106 - Input.txt").readlines.map!(&:strip).join
output = []

inputa = "this is a test"
inputb = "wokka wokka"

puts hammingdistance(stringtobytearray(inputa), stringtobytearray(inputb))

b64test = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"

puts bytearraytostring(base64tobytearray(b64test))
