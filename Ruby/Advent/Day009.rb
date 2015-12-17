input = open("Day009-input.txt").readlines.map!(&:strip)
#input = open("Day009-input-test.txt").readlines.map!(&:strip)

locations = Hash.new{Array.new}

for string in input
	string = string.split
	from = string[0]
	to = string[2]
	distance = string[-1]
	locations[from] = locations[from] << (to + " " + distance) 
	locations[to] = locations[to] << (from + " " + distance) 
end

for distances in locations
	distances[1] << (distances[0] + " 0")
	locations[distances[0]] = distances[1].sort
end

locationdistances = Array.new
for distances in locations.sort
	locationdistances << distances[1].map{|distance| distance.split[1].to_i}
end

numberoflocations = locations.length
locationorders = (0..numberoflocations-1).to_a.permutation
lowestsum = 0
highestsum = 0

for order in locationorders
	orderbackup = order.dup.reverse
	visited = Array.new
	distancesfromhere = locationdistances[order.pop]

	while !order.empty?
		nextdestination = order.pop
		visited << distancesfromhere[nextdestination]
		distancesfromhere = locationdistances[nextdestination]
	end
	
	sum = visited.inject(:+)	
	if (lowestsum == 0) | (sum < lowestsum)
		if visited.count(0) == 0
			puts sum.to_s + ": " + orderbackup.to_s + ": " + visited.to_s
			lowestsum = sum
		end
	end
	if (sum > highestsum)
		if visited.count(0) == 0
			puts sum.to_s + ": " + orderbackup.to_s + ": " + visited.to_s
			highestsum = sum
		end
	end
end
puts "Finished"
puts lowestsum
puts highestsum
