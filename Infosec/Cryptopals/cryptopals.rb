require "openssl"
require "digest"
require "securerandom"
require "stringio"

def console(object)
	print object.to_s; puts
end

def getlowerbits(number, numberofbits)
	return number & Array.new(numberofbits){1}.join.to_i(2)
end

def getupperbits(number, numberofbits)
	return number & Array.new(numberofbits){1}.join.ljust(32, "0").to_i(2)
end

def padbytearraywithPKCS7(bytearray, blocklength)
	padamount = blocklength - (bytearray.length % blocklength)
	finallength = bytearray.length + padamount

	while bytearray.length < finallength
		bytearray << padamount
	end
	return bytearray
end

def checkPKCS7padding(inputbytes)
	padlength = inputbytes[-1]
	properpadding = Array.new(padlength){padlength}
	realpadding = inputbytes[(padlength*-1)..-1]
	(realpadding == properpadding) ? (return true) : (return false)
end

def padbytearraywithPKCS1type2(bytearray, length)
    header = [0, 2]
    bytearray = [0] + bytearray
    paddinglength = length - bytearray.length - header.length
    padding = randombytearray(paddinglength)
    return header + padding + bytearray
end

def removePKCS1type2padding(plainbytes)
    outbytes = []
    byte = plainbytes.pop
    while byte and (byte != 0)
        outbytes << byte
        byte = plainbytes.pop
    end
    outbytes.reverse!
    return outbytes
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

def hexstringtostring(string)
	return bytearraytostring(hexstringtobytearray(string))
end

def hexstringtobytearray(hexstring)
    hexstring = "0" + hexstring unless (hexstring.length % 2 == 0)
	bytearray = hexstring.scan(/.{2}/)
	bytearray.map!{ |hex| hex.to_i(16) }
	return bytearray
end

def bytearraytohexstring(bytearray)
	hexstring = ""
	bytearray.each do |byte| hexstring += byte.to_s(16).rjust(2, "0") end
	return hexstring
end

def bytearraytostring(bytearray)
	return bytearray.pack('C*')
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

#These next few are various heuristics for brute-forcing xorred plaintext
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

		#punctuation = string.scan(/[[:punct:]]/).length
		#score -= punctuation

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

#actual implementations of encryption functions
#versions of functions labeled 'block' do no padding

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
	if checkPKCS7padding(outputbytes)
		outputbytes = outputbytes[0..(outputbytes[-1]*-1)-1]
	else
		raise "Improper PKCS7 padding."
	end

	return outputbytes
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

	outputbytes = outputblocks.flatten
	if checkPKCS7padding(outputbytes)
		outputbytes = outputbytes[0..(outputbytes[-1]*-1)-1]
	else
		raise "Improper PKCS7 padding."
	end

	return outputbytes
end

def generateAES128CTRkeystream(keybytes, nonce, numberofbytes)
	numberofblocks = (numberofbytes/16)+1
	counter = 0

	keystreamblocks = []
	numberofblocks.times do
		inputbytes = [nonce, counter].pack("QQ").bytes
		keystreamblocks << encryptAES128ECBblock(inputbytes, keybytes)
		counter += 1
	end

	return keystreamblocks.flatten[0..numberofbytes-1]
end

def encryptAES128CTR(inputbytes, keybytes, nonce)
	keystreambytes = generateAES128CTRkeystream(keybytes, nonce, inputbytes.length)
	return fixedxor(inputbytes, keystreambytes)
end

def decryptAES128CTR(inputbytes, keybytes, nonce)
	#encrypt/decrypt is the same operation for xorred stream ciphers
	return encryptAES128CTR(inputbytes, keybytes, nonce)
end

def generateMT19937keystream(seed, numberofbytes)
	prng = MT19937.new(seed)

	keystreambytes = []
	numberofbytes.times do
		keystreambytes << prng.extractnumber
	end
	return keystreambytes
end

def encryptMT19937(inputbytes, seed)
	seed = seed & 0xFF #limited to 16 bit seeds
	keystreambytes = generateMT19937keystream(seed, inputbytes.length)
	return fixedxor(inputbytes, keystreambytes)
end

def decryptMT19937(inputbytes, seed)
	#encrypt/decrypt is the same operation for xorred stream ciphers
	return encryptMT19937(inputbytes, seed)
end

def egcd(number, divisor)
	remainder = nil
	currents, lasts = 0, 1
	currentt, lastt = 1, 0
	while remainder != 0
		#grab our quotient and remainder
		quotient = number / divisor
		remainder = number % divisor
		#figure s's and t's
		news = lasts - quotient * currents
		newt = lastt - quotient * currentt

		#rotate
		number, divisor = divisor, remainder
		lasts, currents = currents, news
		lastt, currentt = currentt, newt
	end

	return [number, lasts, lastt]
end

def invmod(number, mod)
	inverse = egcd(number, mod)[1]
	if inverse < 0 then inverse = mod + inverse end
	return inverse
end

def nthrootinteger(n, a, precision = 1e-5)
	x = a
	begin
		prev = x
		x = ((n - 1) * prev + a / (prev ** (n - 1))) / n
	end while (prev - x).abs > precision
	return x
end

def generateRSAKeys(bitlength = 1024)
	p = OpenSSL::BN::generate_prime(bitlength/2).to_i
	q = OpenSSL::BN::generate_prime(bitlength/2).to_i
	n = p * q
	et = (p - 1) * (q - 1)
	e = 3
	d = invmod(e, et)
	return [ [e, n], [d, n] ] #publickey, privatekey
end

def cryptRSAraw(integer, key)
	return modexp(integer, key[0], key[1])
end

def encryptRSAstring(string, key)
    plaininteger = bytearraytohexstring(string.bytes).to_i(16)
    cipherinteger = cryptRSAraw(plaininteger, key)
    return cipherinteger.to_s(16)
end

def decryptRSAstring(hexstring, key)
    bytelength = key[1].to_s(2).length/8
    cipherinteger = hexstring.to_i(16)
    plaininteger = cryptRSAraw(cipherinteger, key)
    plainbytes = hexstringtobytearray(plaininteger.to_s(16))
    plainbytes = Array.new(bytelength - plainbytes.length, 0) + plainbytes
    return plainbytes
end

def cryptRSAstring(string, privatekey)
    hexstring = bytearraytohexstring(string.bytes)
	stringinteger = hexstring.to_i(16)
	return cryptRSAraw(stringinteger, privatekey).to_s(16)
end

def encryptionoracle(inputbytes, mode=rand(2))
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

def generateDSAkeys()
    x = rand(DSAq)
    y = generateDSApublickey(x)
    return [y, x] #public key, private key
end

def generateDSApublickey(privatekey)
    return modexp(DSAg, privatekey, DSAp)
end

def signDSA(message, privatekey)
    r, s = 0, 0
    hash = bytearraytohexstring(sha1(message)).to_i(16)
    while (r == 0) or (s == 0)
        k = rand(DSAq)
        r = computeDSAr(DSAg, k, DSAp, DSAq)
        i = invmod(k, DSAq)
        s = (i * (hash + r * privatekey)) % DSAq
    end
    return [r, s]
end

def computeDSAr(g, k, p, q)
    return modexp(g, k, p) % q
end

def convertDSAktox(message, k, signature)
    r, s = signature
    hash = bytearraytohexstring(sha1(message)).to_i(16)
    return (((s * k) - hash) * invmod(r, DSAq)) % DSAq
end

def verifyDSAsignature(message, publickey, signature)
    hash = bytearraytohexstring(sha1(message)).to_i(16)
    r, s = signature
    return false unless ( (r > 0) and (r < DSAq) )
    return false unless ( (s > 0) and (s < DSAq) )
    w = invmod(s, DSAq)
    u_one = (hash * w) % DSAq
    u_two = (r * w) % DSAq
    #Compute v = (((g**u1)*(y**u2)) mod p) mod q.
    v = ((modexp(DSAg, u_one, DSAp) * modexp(publickey, u_two, DSAp)) % DSAp) % DSAq
    return true if v == r
    return false
end

def outnumber(number)
	number = number & 0xFFFFFFFF
	print number
	print " - "
	print number.to_s(2).rjust(32, "0")
	puts
end

def testoutput(output, validoutput)
	if output == validoutput
		puts("SUCCESS!")
	else
		puts("FAILURE!")
	end
end

#Adapted from: http://rosettacode.org/wiki/Modular_exponentiation#Ruby
def modexp(number, exponent, mod)
	exponent < 0 and raise ArgumentError, "negative exponent"
	result = 1
	base = number % mod
	until exponent.zero?
		if exponent.odd? then result = (result * base) % mod end
		exponent >>= 1
		base = (base * base) % mod
	end
	return result
end

class MT19937
	def initialize(seed)
		#initialize the index to 0
		@index = 624
		@mt = Array.new(624){0}
		@mt[0] = seed
		(1..@mt.length-1).each do |i|
			prev = @mt[i - 1]
			@mt[i] = self.truncate(0x6c078965	* (prev ^ prev >> 30) + i)
		end
	end

	def setstate(newmt)
		@mt = newmt
		self.twist
	end

	def truncate(number)
		return 0xFFFFFFFF & number
	end

	def extractnumber
		if @index >= 624 then self.twist end

		number = @mt[@index]

		# Right shift by 11 bits
		number = number ^ number >> 11
		# Shift y left by 7 and take the bitwise and of 2636928640
		number = number ^ number << 7 & 0x9d2c5680
		# Shift y left by 15 and take the bitwise and of y and 4022730752
		number = number ^ number << 15 & 0xefc60000
		# Right shift by 18 bits
		number = number ^ number >> 18

		@index += 1

		return self.truncate(number)
	end

	def twist
		(0..@mt.length-1).each do |i|
			# Get the most significant bit and add it to the less significant
			# bits of the next number
			number = (@mt[i] & 0x80000000) + (@mt[(i + 1) % 624] & 0x7fffffff)
			number = self.truncate(number)
			@mt[i] = @mt[(i + 397) % 624] ^ number >> 1

			if number % 2 != 0
				@mt[i] = @mt[i] ^ 0x9908b0df
			end
		end

		@index = 0
	end
end

def reverseMT19937tempering(number)
	#Reverse right shift by 18 bits and xor
	number = number ^ number >> 18

	#Reverse shift y left by 15 and take the bitwise and of y and 4022730752
	number = number ^ number << 15 & 0xefc60000

	#Reverse shift y left by 7 and take the bitwise and of 2636928640
	constant = 0x9d2c5680
	andedlower14bits = (getlowerbits(number, 7) << 7) & constant
	originallower14bits = getlowerbits(number ^ andedlower14bits, 14)
	andedlower21bits = (originallower14bits << 7) & constant
	originallower21bits = getlowerbits(number ^ andedlower21bits, 21)
	andedlower28bits = (originallower21bits << 7) & constant
	originallower28bits = getlowerbits(number ^ andedlower28bits, 28)
	anded32bits = (originallower28bits << 7) & constant
	number = getlowerbits(number ^ anded32bits, 32)

	#Reverse right shift by 11 bits
	originaltop11bits = getupperbits(number, 11)
	rshiftedtop22bits = originaltop11bits >> 11
	originaltop22bits = getupperbits(number ^ rshiftedtop22bits, 22)
	rshiftedoriginal32bits = originaltop22bits >> 11
	number = number ^ rshiftedoriginal32bits

	return number & 0xFFFFFFFF
end

DiffieHellman_p = 0xffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552bb9ed529077096966d670c354e4abc9804f1746c08ca237327ffffffffffffffff
DiffieHellman_g = 2

def diffiehellman(p, g)
	privatekey = rand(1..p)
	publickey = modexp(g, privatekey, p)

	dict = Hash.new()
	dict["p"], dict["g"] = p, g
	dict["privatekey"], dict["publickey"] = privatekey, publickey
	return dict
end

def diffiehellmansessionkey(sessiondict, partnerpublickey)
	key = modexp(partnerpublickey, sessiondict["privatekey"], sessiondict["p"])
	sessiondict["sessionkey"] = key
	return sessiondict
end

# Calculates SHA-1 message digest of _string_. Returns binary digest.
# From: http://rosettacode.org/wiki/SHA-1#Ruby
def sha1(string,
		pad = true,
		h = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0])
	# functions and constants
	mask = 0xffffffff

	s = proc{|n, x| ((x << n) & mask) | (x >> (32 - n))}
	f = [
		proc {|b, c, d| (b & c) | (b.^(mask) & d)},
		proc {|b, c, d| b ^ c ^ d},
		proc {|b, c, d| (b & c) | (b & d) | (c & d)},
		proc {|b, c, d| b ^ c ^ d},
	].freeze

	k = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6].freeze

	if pad
		string = sha1padding(string)
	end

	if string.size % 64 != 0
		fail "failed to pad to correct length"
	end

	#hashing
	io = StringIO.new(string)
	block = ""

	while io.read(64, block)
		w = block.unpack("N16")

		# Process block.
		(16..79).each {|t| w[t] = s[1, w[t-3] ^ w[t-8] ^ w[t-14] ^ w[t-16]]}

		a, b, c, d, e = h
		t = 0
		4.times do |i|
			20.times do
				temp = (s[5, a] + f[i][b, c, d] + e + w[t] + k[i]) & mask
				a, b, c, d, e = temp, a, s[30, b], c, d
				t += 1
			end
		end

		[a,b,c,d,e].each_with_index {|x,i| h[i] = (h[i] + x) & mask}
	end
	return h.pack("N5").bytes
end

def sha1string(string)
    return bytearraytohexstring(sha1(string))
end

def sha1padding(string)
		mask = 0xffffffff

		stringbytes = string.bytes
		bit_len = stringbytes.length << 3

		stringbytes << 0x80

		while (stringbytes.length % 64) != 56
			stringbytes << 0x00
		end

		string = bytearraytostring(stringbytes)
		string += [bit_len >> 32, bit_len & mask].pack("N2")
		return string
end

def generateHMACSHA1(string, keystring)
	blocksize = 64 #bytes

	keybytes = keystring.bytes
	while keybytes.length < 64
		keybytes << 0x00
	end
	keystring = bytearraytostring(keybytes)

	innerkeypadding = bytearraytostring(fixedxor(keybytes, Array.new(blocksize){0x36}))
	innerhash = bytearraytostring(sha1(innerkeypadding + string))

	outerkeypadding = bytearraytostring(fixedxor(keybytes, Array.new(blocksize){0x5c}))
	hashbytes = sha1(outerkeypadding  + innerhash)
	return bytearraytohexstring(hashbytes)
end

def generateHMACSHA256(string, keystring)
	blocksize = 64 #bytes

	keybytes = keystring.bytes
	while keybytes.length < 64
		keybytes << 0x00
	end
	keystring = bytearraytostring(keybytes)

	innerkeypadding = bytearraytostring(fixedxor(keybytes, Array.new(blocksize){0x36}))
	innerhash = sha256(innerkeypadding + string)

	outerkeypadding = bytearraytostring(fixedxor(keybytes, Array.new(blocksize){0x5c}))
	hexstring = sha256(outerkeypadding  + innerhash)
	return hexstring
end

def sha256(string)
	hash = Digest::SHA2.new(256)
	output = hash.update(string).hexdigest
	return output
end

def startSRPsession(n, g, k, email, password)
	dict = Hash.new()
	dict["N"], dict["g"], dict["k"] = n, g, k
	dict["privatekey"] = rand(2**64)
	dict["useremail"], dict["userpassword"] = email, password
	return dict
end

def initializeSRPserver(server)
	#generate salt as a random integer
	server["salt"] = rand(2**64).to_s(16)

	#generate sha256(salt + password) and convert to integer x
	x = sha256(server["salt"] + server["userpassword"]).to_i(16)
	#generate v = g**x % N
	server["userpasswordhash"] = modexp(server["g"], x, server["N"])
	server.delete("userpassword")

	server["peruserpublickey"] = server["k"] * server["userpasswordhash"] +
		modexp(server["g"], server["privatekey"], server["N"])
end

def initializeSRPclient(client)
	client["publickey"] = modexp(client["g"], client["privatekey"], client["N"])
end

def generateSRPserversessionkey(server, useremail, clientpublickey)
	#receive email and public key(a la Diffie Hellman) to server
	server["useremail"], server["clientpublickey"] = useremail, clientpublickey

	#generate sha256(clientpublickey + serverpublickey) as integer u
	uH = sha256(server["peruserpublickey"].to_s(16) +
		server["clientpublickey"].to_s(16))
	u = uH.to_i(16)

	#generate S = (A * v**u) ** b % N, K = sha256(S)
	s = modexp( ( server["clientpublickey"] *
				modexp(server["userpasswordhash"],  u, server["N"] ) ),
				server["privatekey"],
				server["N"])
	sK = sha256(s.to_s(16))

	#HMAC-SHA256(K, salt)
	server["HMAC"] = generateHMACSHA256(sK, server["salt"])
end

def generateSRPclientsessionkey(client, salt, serverpublickey)
	#receive salt and public key(kv + g**b % N)
	client["salt"], client["serverpublickey"] = salt, serverpublickey

	#generate sha256(clientpublickey + serverpublickey) as integer u
	uH = sha256(client["serverpublickey"].to_s(16) + client["publickey"].to_s(16))
	u = uH.to_i(16)

	#generate sha256(salt + password) and convert to integer x
	x = sha256(client["salt"] + client["userpassword"]).to_i(16)

	#generate S = (B - k * g**x)**(a + u * x) % N, K = sha256(S)
	s = modexp( ( client["serverpublickey"] - client["k"] *
				modexp(client["g"], x, client["N"]   )      ),
				( client["privatekey"] + u * x ), client["N"] )
	sK = sha256(s.to_s(16))

	#HMAC-SHA256(K, salt)
	client["HMAC"] = generateHMACSHA256(sK, client["salt"])
end

# Calculates MD4 message digest of _string_.
# From: http://rosettacode.org/wiki/MD4#Ruby
def md4(string, pad = true, registers = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476])
	# functions
	mask = (1 << 32) - 1
	f = proc {|x, y, z| x & y | x.^(mask) & z}
	g = proc {|x, y, z| x & y | x & z | y & z}
	h = proc {|x, y, z| x ^ y ^ z}
	r = proc {|v, s| (v << s).&(mask) | (v.&(mask) >> (32 - s))}

	# initial hash
	a, b, c, d = registers

	if pad
		string = md4padding(string)
	end

	if string.size % 64 != 0
		fail "failed to pad to correct length"
	end

	io = StringIO.new(string)
	block = ""

	while io.read(64, block)
		x = block.unpack("V16")

		# Process this block.
		aa, bb, cc, dd = a, b, c, d

		[0, 4, 8, 12].each {|i|
			a = r[a + f[b, c, d] + x[i],  3]; i += 1
			d = r[d + f[a, b, c] + x[i],  7]; i += 1
			c = r[c + f[d, a, b] + x[i], 11]; i += 1
			b = r[b + f[c, d, a] + x[i], 19]
		}

		[0, 1, 2, 3].each {|i|
			a = r[a + g[b, c, d] + x[i] + 0x5a827999,  3]; i += 4
			d = r[d + g[a, b, c] + x[i] + 0x5a827999,  5]; i += 4
			c = r[c + g[d, a, b] + x[i] + 0x5a827999,  9]; i += 4
			b = r[b + g[c, d, a] + x[i] + 0x5a827999, 13]
		}

		[0, 2, 1, 3].each {|i|
			a = r[a + h[b, c, d] + x[i] + 0x6ed9eba1,  3]; i += 8
			d = r[d + h[a, b, c] + x[i] + 0x6ed9eba1,  9]; i -= 4
			c = r[c + h[d, a, b] + x[i] + 0x6ed9eba1, 11]; i += 8
			b = r[b + h[c, d, a] + x[i] + 0x6ed9eba1, 15]
		}

		a = (a + aa) & mask
		b = (b + bb) & mask
		c = (c + cc) & mask
		d = (d + dd) & mask
	end

	[a, b, c, d].pack("V4").bytes
end

def md4padding(string)
		mask = (1 << 32) - 1
		bit_len = string.size << 3

		stringbytes = string.bytes
		stringbytes << 0x80
		while (stringbytes.length % 64) != 56
			stringbytes << 0x00
		end
		string = bytearraytostring(stringbytes)

		string = string.force_encoding('ascii-8bit')
		string += [bit_len & mask, bit_len >> 32].pack("V2")
		return string
end
