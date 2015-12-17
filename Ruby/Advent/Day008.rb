input = open("Day008-input.txt").readlines.map!(&:strip)
#input = open("Day008-input-test.txt").readlines.map!(&:strip)

codecharacters = 0
parsedcharacters = 0

def parse(string)
	print string + " "

	#kill end quotes
	string = string[1..-2]

	#kill escaped chars
	for match in string.scan(/(\\x[0-9A-Fa-f]{2})/)
		match = match[0]
		#string.gsub!(match, match[-2..-1].to_i(16).chr)
		string.gsub!(match, "*")
	end 

	#kill escaped quotes
	string.gsub!(/\\\"/, '*')

	#kill escaped slashes
	string.gsub!(/\\\\/, "*")
	
	print string + "\n"
	return string
end

def escape(string)
	print string + " "
	string.gsub!(/\\/, "11")
	string.gsub!(/\"/, "22")
	string = '"'+string+'"'
	print string + "\n"
	return string
end
	

for string in input
	codecharacters += string.length
	parsedcharacters += parse(string).length
end

print "Code Characters: " + codecharacters.to_s
puts ""
print "Parsed Characters: " + parsedcharacters.to_s
puts ""
print "Difference: " + (codecharacters - parsedcharacters).to_s
puts ""

#Part 2
escapedlength = 0
for string in input
	escapedlength += escape(string).length
end

print "Difference(Escaping): " + (escapedlength - codecharacters).to_s
puts ""
	
