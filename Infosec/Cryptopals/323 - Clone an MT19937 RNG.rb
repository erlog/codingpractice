require_relative 'cryptopals'

prng = MT19937.new(1000)
state = []

624.times do 
	state << reverseMT19937tempering(prng.extractnumber) 
end

cloned = MT19937.new(0)
cloned.setstate(state)

rand(1..1000).times do
	prng.extractnumber
	cloned.extractnumber
end

puts prng.extractnumber
puts cloned.extractnumber

testoutput(prng.extractnumber, cloned.extractnumber)
