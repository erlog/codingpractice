require_relative "cryptopals"

inputs = open("108 - Input.txt").readlines.map!{ |line| hexstringtobytearray(line.strip) }

bestscore = 0
bestindex = 0

inputs.each_with_index do |input, index|
	averagebyte = averagebytearray(input)
	score = distancefrombytemean(averagebyte)
	if score > bestscore
		bestscore, bestindex = score, index
	end 
end

puts ["ECB at Index: ", bestindex].join
puts ["Deviation from mean: ", bestscore].join

testoutput(bestindex, 133)
