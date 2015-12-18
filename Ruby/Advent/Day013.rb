input = open("Day013-input.txt").readlines.map!(&:strip)

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

def computehappiness(guestlistpairs)
	happinesschange = 0
	for pair in guestlistpairs
		firstkey = pair[0].to_s + pair[1].to_s
		secondkey = pair[1].to_s + pair[0].to_s
		happinesschange += GuestData[firstkey]
		happinesschange += GuestData[secondkey]
	end
	return happinesschange
end

def getpairs(guestlist)
	return guestlist.each_cons(2).to_a << [guestlist[-1], guestlist[0]]
end

GuestData = Hash.new()
guestnames = Array.new

for line in input
	line = line.delete(".").split
	guestnames << line[0]
	pairnames = line[0] + line[-1]
	happiness = line[3].to_i
	happiness *= -1 unless (line[2] == "gain")

	GuestData[pairnames] = happiness
end

guestnames = guestnames.uniq

#Add myself to the list for part 2
guestnames.each do |person|
	GuestData["John"+person] = 0
	GuestData[person+"John"] = 0
end

guestnames << "John"

maxchange = 0
bestarrangement = Array.new

for arrangement in guestnames.permutation
	pairs = getpairs(arrangement)
	happinesschange = computehappiness(pairs)

	if (happinesschange > maxchange)
		maxchange = happinesschange
		bestarrangement = arrangement
		outtoconsole [pairs, happinesschange]
	end

end

outtoconsole maxchange
