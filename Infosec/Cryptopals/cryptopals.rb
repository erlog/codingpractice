require 'openssl'
require 'securerandom'

def padbytearraywithPKCS7(bytearray, blocklength)
	padamount = blocklength - (bytearray.length % blocklength)
	finallength = bytearray.length + padamount

	while bytearray.length < finallength 
		bytearray << padamount 
	end
	return bytearray
end

def transposebytearray(bytearray, numberofstrips)
	transposedbytes = Array.new(numberofstrips){ Array.new() }
	bytearray.each_slice(numberofstrips) do |slice|
		slice.each_with_index do |byte, index| 
			transposedbytes[index] << byte
		end
	end
	return transposedbytes
end

def randombytearray(length)
	return SecureRandom.random_bytes(length).bytes
end


def hexstringtobytearray(hexstring)
	bytearray = hexstring.scan(/.{2}/)
	bytearray.map!{ |hex| hex.to_i(16) }
	return bytearray
end

def bytearraytohexstring(bytearray)
	bytearray.map!{ |hex| hex.to_s(16).rjust(2, "0")}
	return bytearray.join
end

def bytearraytostring(bytearray)
	begin
		return bytearray.map(&:chr).join
	rescue RangeError
		return ""
	end
end

def stringtobytearray(string)
	return string.bytes
end

Base64Symbols = ("A".."Z").to_a +
			("a".."z").to_a +
			("0".."9").to_a +
			["+","/"]

def bytearraytobase64(bytearray)
	#convert to padded binary
	bytearray.map!{|x| x.to_s(2).rjust(8,"0")}
	#recombine and break into chunks of 6 binary values
	bitchunks = bytearray.join.split("").each_slice(6).to_a

	#rejoin the groups of 6 and pad the last sextet with zeroes
	bitchunks.map!(&:join)
	bitchunks[-1] = bitchunks[-1].ljust(6, "0")

	#convert the sextets to base64 symbols and join them into a string
	bitchunks.map!{ |chunk| Base64Symbols[chunk.to_i(2)]}
	output = bitchunks.join

	#communicate padding
	remainder = output.length % 4
	if remainder == 3 then output += "="
	elsif remainder == 2 then output += "=="
	end

	return output
end

def base64tobytearray(base64string)
	binarychunks = []
	paddingamount = base64string.count("=")

	base64string.tr("=", "").split("").each do |char| 
		binarychunks << Base64Symbols.index(char).to_s(2).rjust(6, "0")
	end

	binarychunks = binarychunks.join.split("").each_slice(8).to_a

	if paddingamount > 0 then binarychunks.pop end

	return binarychunks.map!{ |chunk| chunk.join.to_i(2) }
end

def fixedxor(bytearray, xorbytes)
	output = []
	bytearray.zip(xorbytes).each do |a, b|
		output << (a ^ b)
	end

	return output
end

def singlebytexor(bytearray, xorbyte)
	output = bytearray.map{ |byte| (byte ^ xorbyte)}
	return output
end

def repeatingkeyxor(bytearray, xorbytes)
	output = []
	bytearray.zip(xorbytes.cycle).each do |byte, xorbyte|
		output <<	(byte ^ xorbyte)
	end

	return output
end

def averagestring(string)
	bytearray = string.bytes
	return (bytearray.inject(:+).to_f/bytearray.length)
end

def averagebytearray(bytearray)
	return (bytearray.inject(:+).to_f/bytearray.length)
end

def distancefrombytemean(average)
	#mean of random data should be 127
	return (127 - average).abs
end

def distancefromperfectaverage(average)
	#88.235 is the best average for an English string
	return (88.235 - average).abs
end

def distancefromaveragewordlength(average)
	#5.1 is the average word length usually
	return (5.1 - average).abs
end

def scorestring(string)
	if !string.empty? & string.force_encoding("UTF-8").ascii_only?
		score = 100

		#dock points for distance away from average English string
		average = averagestring(string)
		score -= (distancefromperfectaverage(average))

		wordlength = (string.length / string.split(" ").length.to_f)
		score -= (distancefromaveragewordlength(wordlength))

		return score
	end
	return 0
end

def computeaveragehammingofblocks(bytearray, blocksize)
	hammingdistances = []
	bytearray.each_slice(blocksize).each_slice(2) do |blockone, blocktwo|
		if (blockone != nil) & (blocktwo != nil)
			hammingdistances << computehammingdistance(blockone, blocktwo)
		end
	end
	return (hammingdistances.inject(:+)/hammingdistances.length.to_f)/blocksize
end

def computehammingdistance(bytearrayone, bytearraytwo)
	if bytearrayone.length != bytearraytwo.length
		maxlength = [bytearrayone.length, bytearraytwo.length].max
		bytearrayone.fill(0, (bytearrayone.length)..(maxlength))
		bytearraytwo.fill(0, (bytearraytwo.length)..(maxlength))
	end

	#xor returns 1 if bits are different
	xorredbytes = fixedxor(bytearrayone, bytearraytwo)

	return xorredbytes.map!{ |byte| byte.to_s(2) }.join.count("1")
end

def findbestxorbyte(bytearray)
	bestxorbyte = 0 
	bestscore = 0

	(1..255).each do |xorbyte|
		xorredstring = bytearraytostring(singlebytexor(bytearray, xorbyte))

		score = scorestring(xorredstring)
		if score > bestscore
			bestxorbyte, bestscore = xorbyte, score
		end
	end

	return bestxorbyte 
end

def findrepeatingkeyxorkeylength(bytearray)
	bestkeylength = 0
	bestaverage = 0

	(2..12).each do |keylength|
		puts keylength
		hammingdistances = []

		bytearray.each_slice(keylength).each_slice(2).to_a[0..6].each do |pair|
			hammingdistances << computehammingdistance(pair[0], pair[1])
		end

		average = (hammingdistances.inject(:+)/hammingdistances.length.to_f)
		average = (average/keylength)

		if (bestaverage == 0) | (average < bestaverage)
			bestkeylength, bestaverage = keylength, average
		end
	end
	
	return bestkeylength
end

def findrepeatingkeyxorkey(transposedbytes)
	key = []
	transposedbytes.each do |strip| key << findbestxorbyte(strip) end
	return key
end

def decryptAES128ECBblock(inputblock, keybytes)
	input, key = bytearraytostring(inputblock), bytearraytostring(keybytes) 
	decipher = OpenSSL::Cipher::AES.new(128, 'ECB')
	decipher.decrypt
	decipher.key = key
	decipher.padding = 0
	return stringtobytearray(decipher.update(input) + decipher.final)
end

def decryptAES128ECB(inputbytes, keybytes)
	blocks = inputbytes.each_slice(16).to_a
	outputblocks = []

	blocks.each do |block|
		decipherblock = decryptAES128ECBblock(block, keybytes)
		outputblocks << decipherblock
	end
	
	outputbytes = outputblocks.flatten
	outputbytes = outputbytes[0..(outputbytes[-1]*-1)-1]
end

def encryptAES128ECBblock(inputblock, keybytes)
	input, key = bytearraytostring(inputblock), bytearraytostring(keybytes) 
	cipher = OpenSSL::Cipher::AES.new(128, 'ECB')
	cipher.encrypt
	cipher.key = key
	cipher.padding = 0
	return stringtobytearray(cipher.update(input) + cipher.final)
end

def encryptAES128ECB(inputbytes, keybytes)
	blocks = padbytearraywithPKCS7(inputbytes, 16).each_slice(16).to_a
	outputblocks = []

	blocks.each do |block|
		cipherblock = encryptAES128ECBblock(block, keybytes)
		outputblocks << cipherblock
	end
	
	return outputblocks.flatten 
end
	
def decryptAES128CBC(inputbytes, keybytes, ivbytes)
	blocks = inputbytes.each_slice(16).to_a

	previousdecipherblock = ivbytes
	outputblocks = []

	blocks.each do |block|
		decipherblock = decryptAES128ECBblock(block, keybytes)
		xorblock = fixedxor(decipherblock, previousdecipherblock)
		previousdecipherblock = block
		outputblocks << xorblock
	end

	return outputblocks.flatten
end

def encryptAES128CBC(inputbytes, keybytes, ivbytes)
	previouscipherblock = ivbytes
	outputblocks = []

	padbytearraywithPKCS7(inputbytes, 16).each_slice(16) do |block|
		xorblock = fixedxor(block, previouscipherblock)
		cipherblock = encryptAES128ECBblock(xorblock, keybytes)
		previouscipherblock = cipherblock
		outputblocks << cipherblock
	end

	return outputblocks.flatten
end

def encryptionoracle(inputbytes, mode)
	keybytes = randombytearray(16)
	ivbytes = randombytearray(16)

	padbyte = Base64Symbols.sample.bytes[0]
	pad = Array.new(rand(5..10)){ padbyte } 
	inputbytes = pad + inputbytes + pad 
	inputbytes = padbytearraywithPKCS7(inputbytes, 16)

	if mode == 1 
		return encryptAES128CBC(inputbytes, keybytes, ivbytes)
	else
		return encryptAES128ECB(inputbytes, keybytes)
	end
end

def testoutput(output, validoutput)
	if output == validoutput
		puts("SUCCESS!")
	else
		puts("FAILURE!")
	end
end
