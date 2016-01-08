require_relative 'cryptopals'


prng = MT19937.new(1)
1000000.times do 
	prng.extractnumber
end

	
