require "json"

input = open("Day012-input.txt").read
Output = open("Day012-output.txt", "w")

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

def prunered(chunk)
	if chunk.is_a?(Fixnum)
		return false

	elsif chunk.is_a?(String) 
		return (chunk == "red")

	elsif chunk.is_a?(Hash) 
		markfordeletion = false
		chunk.each do |key, value| 
			if prunered(value) then markfordeletion = true end
		end
		if markfordeletion then Output.write(chunk.to_json); Output.write("\n") end

	elsif chunk.is_a?(Array)
		chunk.each do |item| 
			prunered(item) 
		end
	else 
		outtoconsole ["WHAT!", chunk.class]
	end

	return false
end

total = input.scan(/-?\d+/).map!(&:to_i).inject(:+)
outtoconsole ["Part 1 Total", total]

jsonchunks = JSON.parse(input)

prunered(jsonchunks)
Output.close

redobjectinput = open("Day012-output.txt", "r")
for line in redobjectinput
	line = line.strip
	input = input.gsub(line, '"!Deleted Object!"')
end


output = open("Day012-output.txt", "w")
output.write(JSON.pretty_generate(JSON.parse(input)))
output.close

total = input.scan(/-?\d+/).map!(&:to_i).inject(:+)
outtoconsole ["Part 2 Total", total]
