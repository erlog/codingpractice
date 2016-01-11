require_relative 'cryptopals'

Seed = rand(0..0xFF)

def oracle(inputbytes)
	inputbytes = randombytearray(rand(1..31)) + inputbytes
	return encryptMT19937(inputbytes, Seed)
end

def passwordresettoken()
	return MT19937.new(Time.now.to_i).extractnumber
end

def testpasswordresettoken(token)
	starttime = Time.now.to_i - 3600 #past hour
	(starttime..Time.now.to_i).each do |time|
		if MT19937.new(time).extractnumber == token
			return true
		end
	end
	return false
end

input = "A"*14
cipherbytes = oracle(input.bytes)

padlength = cipherbytes.length - 14
pad = " "*padlength
knowncipherbytes = cipherbytes[-14..-1]

i = 0
while (i <= 0xFF)
	possiblecipherbytes = encryptMT19937(pad.bytes + input.bytes, i)[-14..-1]
	break unless (possiblecipherbytes != knowncipherbytes)
	i += 1
end

puts ["Discovered seed: ", i].join
testoutput(i, Seed)

outputs = []

token = passwordresettoken()
puts ["Testing ", token].join
outputs << testpasswordresettoken(token)
token = rand(0xFFFFFFFF)
puts ["Testing ", token].join
outputs << testpasswordresettoken(token)

testoutput([true, false], outputs)




