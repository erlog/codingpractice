require_relative 'cryptopals'

input = "A"*128 

outputs = []

def metrics(bytearray, outputstring)
	print outputstring
	blocks = bytearray.each_slice(16).to_a
	if blocks[2] == blocks[3]
		puts "ECB!"
	else
		puts "CBC!"
	end
end

encryptedbytes = encryptionoracle(input.bytes, 1)
metrics(encryptedbytes, "CBC check: ")
encryptedbytes = encryptionoracle(input.bytes, 0)
metrics(encryptedbytes, "ECB check: ")

puts "Success if those match properly."
