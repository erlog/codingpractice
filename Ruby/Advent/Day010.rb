input = ARGV[0].strip
revolutions = ARGV[1].to_i

def outtoconsole(thing)
	print thing.to_s + "\n"
end

def splitsequence(sequence)
	output = []
	sequence = sequence.reverse.split("") #we can't pop elements from a string
	if sequence.length == 1 then return sequence end 
	
	previous = sequence.pop
	chunk = previous

	while true 
		current = sequence.pop
		if current == previous
			chunk += current
		else
			output << chunk
			chunk = current
		end

		if sequence.empty?
			output << chunk
			break;
		else	
			previous = current
		end
	end

	return output		 
end

def convertsequence(sequence)
	sequence.map!{ |element|
		element = element.length.to_s + element[0]
	}
	return sequence
end

current = input
revolutions.times do
	split = splitsequence(current)
	converted = convertsequence(split)
	current = converted.join
	outtoconsole(current.length)
end

