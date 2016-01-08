require_relative 'cryptopals'


firstresponse = 36427181
validoutput = "2016-01-08 14:01:13 +0900"

starttime = Time.now.to_i - (86400*0.5)
prng = MT19937.new(starttime)
puts starttime

while prng.extractnumber != firstresponse
	if starttime % 10000 == 0 then puts starttime end	
	starttime += 1
	prng = MT19937.new(starttime)
end

puts "---"
puts Time.at(starttime).to_s
testoutput(Time.at(starttime).to_s, validoutput)
	
