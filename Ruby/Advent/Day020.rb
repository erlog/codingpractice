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

start = 29000000

#PART 1
guess = 0 
#665280
max = 0
while true
	total = 0
	(1..(guess/2)+1).each do |index|
		if (guess % index == 0)
			total += (index*10)
		end
	end
	total += (guess * 10)
	if total > max
		max = total
		outtoconsole [guess, total]
	end
	if total >= start
		quit()
	end
	guess += 20
end

