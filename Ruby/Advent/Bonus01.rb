input = open("Bonus01-input.txt").readlines.map!(&:split)

#I hate Ruby so much
class Integer; def to_bool; !self.zero?; end; end
class FalseClass; def to_i; 0; end; end
class TrueClass; def to_i; 1; end; end
class Fixnum; def empty?; false; end; end
#Just pretend you didn't see this and that I'm a better programmer

def outtoconsole(things)
	sep = ", "
	things = [things]
	print things.join(sep).to_s + "\n"
end

def getattributes(guestdata, guestarray)
	attributes = Array.new
	guestarray.each do |guest| attributes << guestdata[guest] end
	return attributes.flatten.reject(&:empty?).uniq
end

guestdata = Hash.new(Array.new)
doesntlike = Hash.new(Array.new)
guestages = Hash.new
guestnames = []

input.each do |line|
	name = line[0]
	if line[1] == "is" 
		guestdata[name] = (guestdata[name] + [line[-1]])
	elsif line[1] == "will" 
		doesntlike[name] = (doesntlike[name] + [line[-1]])
	elsif line[1] == "age" 
		age = line[-1].to_i
		guestdata[name] = (guestdata[name] + ["50"]) unless (age < 50) 
		guestages[name] = age 
	end
end
guestnames = (guestdata.keys + doesntlike.keys).uniq.sort
matches = []

guestnames.permutation.each do |guests|
	tables = guests.each_slice(4).to_a
	goodparty = true
	tables.each do |tablemates|
		attributes = getattributes(guestdata, tablemates)
		dislikes = getattributes(doesntlike, tablemates)
		total = attributes.length + dislikes.length
		combined = attributes + dislikes
		goodparty = false unless (total == combined.uniq.length)
	end
	if goodparty 
		combinedages = [] 
		tables.each do |tablemates|
			combinedages << getattributes(guestages, tablemates).inject(:+)
		end
		answer = combinedages.inject(:*)	
		if !matches.include?(answer)
			matches << answer
			tables.each do |table|
				outtoconsole table
			end
			outtoconsole ["Answer", answer]
		end
	end
end

