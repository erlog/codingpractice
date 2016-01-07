input = open("Day021-input.txt").readlines.map!(&:strip)

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

bosshp = input[0].split[-1].to_i
bossdamage = input[1].split[-1].to_i
bossarmor = input[2].split[-1].to_i

herohp = 100 
herodamage = 7 #90 gold /108 
heroarmor = 4 #31 gold /93

while (herohp > 0) & (bosshp > 0)
	turnherodamage = herodamage - bossarmor
	turnherodamage = 1 unless turnherodamage > 0	
	bosshp -= turnherodamage 
	
	break unless bosshp > 0

	turnbossdamage = bossdamage - heroarmor
	turnbossdamage = 1 unless turnbossdamage > 0	
	herohp -= turnbossdamage 

	outtoconsole ["Boss HP", bosshp, "Hero HP", herohp]
end

outtoconsole "Finished!"
outtoconsole ["Boss HP", bosshp, "Hero HP", herohp]

