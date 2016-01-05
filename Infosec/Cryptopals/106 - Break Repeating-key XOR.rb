require_relative "cryptopals"

input = open("106 - Input.txt").readlines.map!(&:strip).join
output = []

inputa = "this is a test"
inputb = "wokka wokka"

puts hammingdistance(stringtobytearray(inputa), stringtobytearray(inputb))

b64test = "YW55IGNhcm5hbCBwbGVhc3VyZQ=="

puts bytearraytostring(base64tobytearray(b64test))
