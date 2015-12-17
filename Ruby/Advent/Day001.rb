inputfile = open("Day001-input.txt")
input = inputfile.gets.strip

upstairs = input.count("(")
downstairs = input.count(")")

puts input.length
puts upstairs - downstairs

input = input.split("")

currentlevel = 0
input.each_with_index{|stair, index|
	if stair == "("
		currentlevel += 1
	else
		currentlevel += -1
	end

	if currentlevel == -1 then puts index+1 end
} 
