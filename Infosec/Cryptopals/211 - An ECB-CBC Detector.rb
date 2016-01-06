require_relative 'cryptopals'

input = "A"*256 

def metrics(bytearray, outputstring)
	puts outputstring
	blocks = bytearray.each_slice(16).to_a
	blocks.each do |block| print block; puts end
end

encryptedbytes = encryptionoracle(input.bytes, 1)
metrics(encryptedbytes, "CBC: ")
encryptedbytes = encryptionoracle(input.bytes, 0)
metrics(encryptedbytes, "ECB: ")
