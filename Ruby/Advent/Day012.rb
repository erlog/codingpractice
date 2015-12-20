require "json"

input = open("Day012-input.txt").read

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
		return chunk 

	elsif chunk.is_a?(String) 
		if (chunk == "red") 
			return "JOHNDELETEME!"  
		else
			return chunk
		end

	elsif chunk.is_a?(Hash) 
		newchunk = Hash.new
		markfordeletion = false
		chunk.each do |key, value| 
			check = prunered(value)	
			(markfordeletion = true) unless (check != "JOHNDELETEME!" )
			newchunk[key] = check
 		end
		markfordeletion ? (return "!DELETED OBJECT!") : (return newchunk)

	elsif chunk.is_a?(Array)
		newchunk = []
		chunk.each do |item| 
			newchunk << prunered(item) 
		end
		return newchunk
	end

	return chunk 
end

total = input.scan(/-?\d+/).map!(&:to_i).inject(:+)
outtoconsole ["Part 1 Total", total]
outtoconsole ["Part 1 Length", input.length]

jsonchunks = JSON.parse(input)

pruned = prunered(jsonchunks)

total = pruned.to_json.scan(/-?\d+/).map!(&:to_i).inject(:+)
outtoconsole ["Part 2 Total", total]
outtoconsole ["Part 2 Length", pruned.to_json.length]

