input = "hxbxwxba"
input = "hxbxxyzz"

#I hate Ruby so much
class Integer; def to_bool; !self.zero?; end; end
class FalseClass; def to_i; 0; end; end
class TrueClass; def to_i; 1; end; end
#Just pretend you didn't see this and that I'm a better programmer

def outtoconsole(things)
	sep = " -> "
	print things.join(sep).to_s + "\n"
end

def iteratestring(string)
	elements = string.chars
	outstring = ""
	while !elements.empty?
		character = elements.pop
		outstring += iteratecharacter(character)
		break unless character == "z"
	end

	while !elements.empty?
		outstring += elements.pop
	end
	outstring = outstring.reverse
	return outstring	
end

def iteratecharacter(character)
	index = Alphabet.find_index(character)
	index += 1
	index %= 26
	return Alphabet[index]
end

def isvalid(string)
	valid = !scanformatches(string, Bannedcharacters, true).to_bool
	return [false, "Banned Chars"] unless valid
	valid = scanformatches(string, Triplets, true).to_bool
	return [false, "No Triplets"] unless valid
	doublescount = scanformatches(string, Doubles, false)
	valid = (doublescount >= 2)
	return [false, "Not Enough Doubles"] unless valid
	return [valid, "Valid!"]
end

def scanformatches(string, substrings, bailonfirstmatch)
	matches = 0
	if bailonfirstmatch 
		substrings.each{ |substring|	
			matches = string.scan(substring).count
			if matches > 0 then return 1 end
		}
		return 0
	else 
		substrings.each{ |substring|	
			#cast from bool to int below because we don't want to count dupes
			matches += string.scan(substring).count.to_bool.to_i
		}
	end
	return matches
end

Alphabet = ("a".."z").to_a
Triplets = Alphabet.each_cons(3).to_a.map!(&:join)
Doubles = Alphabet.map{|letter| letter = letter + letter}
Bannedcharacters = ["i","o","l"]

input = iteratestring(input) #For part 2
found = isvalid(input)
while !found[0]
	input = iteratestring(input)
	found = isvalid(input)
end 

outtoconsole [input, found]
