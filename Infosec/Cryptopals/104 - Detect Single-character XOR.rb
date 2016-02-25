require_relative "cryptopals"

input = open("104 - Input.txt").readlines.map!(&:strip)
output = []
validoutput = "Now that the party is jumping\n"

beststringinfile = ""
bestscoreinfile = 0

input.each do |hexstring|
	beststring, bestscore = findbestxor(hexstringtobytearray(hexstring))
	puts [bestscore, ": ", beststring].join unless beststring.empty?
	if bestscore > bestscoreinfile
		beststringinfile, bestscoreinfile = beststring, bestscore
	end
end

puts "---"
puts [bestscoreinfile, ": ", beststringinfile].join
puts beststringinfile.inspect
puts validoutput.inspect
testoutput(beststringinfile, validoutput)
