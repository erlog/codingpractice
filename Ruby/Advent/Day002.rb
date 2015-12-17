inputfile = open("Day002-input.txt")
totalwrap = 0
totalribbon = 0

while !inputfile.eof?
	#length, width, height
	input = inputfile.gets.strip.split("x").map!(&:to_i).sort

	wraparea = [(input[0]*input[1]), (input[1]*input[2]), (input[0]*input[2])].sort
	wraparea = wraparea[0] + (2*wraparea.inject(:+))
	
	totalwrap += wraparea
	totalribbon += input.inject(:*) + (input[0] +  input[1])*2
end

puts totalwrap
puts totalribbon
