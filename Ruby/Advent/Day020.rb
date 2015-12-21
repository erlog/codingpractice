input = open("Day020-input.txt").readlines.map!(&:strip)

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

goal = 29000000

#PART 1
housenumber = 660000
#665280
max = 0

while true
	presents = 0
	(1..(housenumber/2)+1).each do |elfnumber|
		if (housenumber % elfnumber == 0) 
			presents += (elfnumber * 10)
		end
	end
	presents += (housenumber*10)
	if presents > max
		outtoconsole [housenumber, presents]
		max = presents
	end
	if presents >= goal 
		break
	end
	housenumber += 20
end

outtoconsole ["Part 1 Finished!", housenumber]

#PART 2
housenumber = housenumber-1000 
#705600
max = 0
while true
	presents = 0
	(1..(housenumber/2)+1).each do |elfnumber|
		if (housenumber % elfnumber == 0) & (housenumber <= (elfnumber*50))
			presents += (elfnumber * 11)
		end
	end
	presents += (housenumber*11)
	if presents > max
		outtoconsole [housenumber, presents]
		max = presents
	end
	if presents >= goal 
		break
	end
	housenumber += 20
end

outtoconsole ["Part 2 Finished!", housenumber]
