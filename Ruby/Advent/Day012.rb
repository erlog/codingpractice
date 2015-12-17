require "json"
input = open("Day012-input.txt").read

#I hate Ruby so much
class Integer; def to_bool; !self.zero?; end; end
class FalseClass; def to_i; 0; end; end
class TrueClass; def to_i; 1; end; end
#Just pretend you didn't see this and that I'm a better programmer

def outtoconsole(things)
	sep = ", "
	print things.join(sep).to_s + "\n"
end

total = input.scan(/-?\d+/).map!(&:to_i).inject(:+)
outtoconsole ["Part 1 Total", total]

jsonchunks = JSON.parse(input)

for key in jsonchunks.keys
	outtoconsole [jsonchunks[key].class]
end
