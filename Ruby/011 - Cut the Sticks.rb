stickcount = gets.strip.to_i
sticks = gets.strip.split(" ").map! {|n| n.to_i}

def findcutpoint(stickarray)
	height = stickarray[0]
	stickarray.each_with_index {|stick, index| return index if stick > height}
end

def mingreaterthan(stickarray, number)
	min = 1001
	stickarray.each {|stick| min = stick if stick > number and stick < min}
	return min
end

sticks.sort!

while sticks.count > 1
	puts sticks.count
	cutpoint = findcutpoint(sticks)
	sticks = sticks[cutpoint..-1]
end

puts sticks.count








