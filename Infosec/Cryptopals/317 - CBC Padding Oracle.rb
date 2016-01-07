require_relative 'cryptopals'

inputs = open("317 - Input.txt").readlines.map!(&:strip)

AESkey = [95, 46, 213, 158, 65, 197, 26, 159, 34, 106, 95, 162, 41, 235, 162, 11]
AESiv = [163, 213, 52, 41, 181, 246, 125, 94, 7, 74, 81, 155, 106, 30, 116, 197]

def encryptionoracle(inputbytes)
	cipherbytes = encryptAES128CBC(inputbytes, AESkey, AESiv)
	return cipherbytes	
end

def paddingoracle(inputbytes)
	decipherbytes = decryptAES128CBC(inputbytes, AESkey, AESiv)
	return checkPKCS7padding(decipherbytes)
end
		

inputs.each do |line|
	inputbytes = base64tobytearray(line)
	cipherbytes = encryptionoracle(inputbytes)
       	puts paddingoracle(cipherbytes)	
end

