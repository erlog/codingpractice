require 'digest'

input = ARGV[0].strip

token = 1

md5 = Digest::MD5.new

while true
	digest = md5.hexdigest(input + token.to_s)
	if digest[0..4] == "00000"
		puts token
		puts digest
		break
	else
		token += 1
	end
end

token = 1
while true
	digest = md5.hexdigest(input + token.to_s)
	if digest[0..5] == "000000"
		puts token
		puts digest
		break
	else
		token += 1
	end
end
