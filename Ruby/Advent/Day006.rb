inputlines = open("Day006-input.txt").readlines

def turnon(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = row[fromloc[0]..toloc[0]].map{true}
			row
	}
end

def turnoff(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = row[fromloc[0]..toloc[0]].map{false} 
			row
	}
end

def toggle(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = 
				row[fromloc[0]..toloc[0]].map{|light| !light}
				row
	}
end

def inclusivearea(from, to)
	xdistance = (from[0] - to[0]).abs
	ydistance = (from[1] - to[1]).abs
	return xdistance*ydistance
end

def outputarray(array)
	outputfile = open("Day006-output.txt", "w")
	array.map{|row| 
		outputfile.write(row) 
		outputfile.write("\n")
	} 
	outputfile.close()
end

lights = Array.new(1000){Array.new(1000){false}}
for line in inputlines
	line = line.split
	if line[0] == "toggle"
		from = line[1].split(",").map(&:to_i)
		to = line[3].split(",").map(&:to_i)
		toggle(lights, from, to)

	elsif line[1] == "on"
		from = line[2].split(",").map(&:to_i)
		to = line[4].split(",").map(&:to_i)
		turnon(lights, from, to)

	elsif line[1] == "off"
		from = line[2].split(",").map(&:to_i)
		to = line[4].split(",").map(&:to_i)
		turnoff(lights, from, to)
	end
end

litlights = lights.to_s.scan("true").length
puts "Lights lit:",litlights

#Part 2
def turnon2(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = row[fromloc[0]..toloc[0]].map{ |light|
				light += 1
			}
			row
	}
end

def turnoff2(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = row[fromloc[0]..toloc[0]].map{ |light|
				(light > 0) ? light -= 1 : light = 0
			} 
			row
	}
end

def toggle2(array, fromloc, toloc)
	array[fromloc[1]..toloc[1]] = array[fromloc[1]..toloc[1]].map { |row|
			row[fromloc[0]..toloc[0]] = row[fromloc[0]..toloc[0]].map{ |light|
				light += 2 
			}
			row
	}
end


lights = Array.new(1000){Array.new(1000){0}}
for line in inputlines
	line = line.split
	if line[0] == "toggle"
		from = line[1].split(",").map(&:to_i)
		to = line[3].split(",").map(&:to_i)
		toggle2(lights, from, to)

	elsif line[1] == "on"
		from = line[2].split(",").map(&:to_i)
		to = line[4].split(",").map(&:to_i)
		turnon2(lights, from, to)

	elsif line[1] == "off"
		from = line[2].split(",").map(&:to_i)
		to = line[4].split(",").map(&:to_i)
		turnoff2(lights, from, to)
	end
end

brightness = 0
lights.map{ |row| brightness+= row.inject(:+) }
puts "Brightness:"
puts brightness
