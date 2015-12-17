input = open("Day017-input.txt").readlines.map!(&:strip).map!(&:to_i)

#I hate Ruby so much
class Integer; def to_bool; !self.zero?; end; end
class FalseClass; def to_i; 0; end; end
class TrueClass; def to_i; 1; end; end
#Just pretend you didn't see this and that I'm a better programmer

def outtoconsole(things)
	sep = ", "
	things = [things]
	print things.join(sep).to_s + "\n"
end

litersofeggnog = 150
bitfield = 0
totalmatches = 0
minimummatches = 0

for bits in (1..(2**20)-1)
	total = 0
	bits = bits.to_s(2).rjust(20, "0")
	containercount = bits.count("1")	
	index = bits.index("1")
	while index
		total += input[index]
		bits[index] = "0"
		index = bits.index("1")
	end	
	
	if total == 150 
		totalmatches += 1
		if containercount == 4 then minimummatches += 1 end 
	end
end

outtoconsole ["DONE!", totalmatches]
outtoconsole ["Minimum", minimummatches]

