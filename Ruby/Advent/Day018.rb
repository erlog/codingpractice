input = open("Day018-input.txt").readlines.map!(&:strip)

#I hate Ruby so much
class Integer; def to_bool; !self.zero?; end; end
class FalseClass; def to_i; 0; end; end
class TrueClass; def to_i; 1; end; end
#Just pretend you didn't see this and that I'm a better programmer

def outtoconsole(things)
	sep = ", "
	things = [things]
	print things.join(sep).to_s + "\n"
end

def countneighborlights(lightarray, coords)
	neighborlights = 0
	neighbors = getneighbors(coords)
	neighbors.each do |lightxy| 
		if getlight(lightarray, lightxy) == "#" then neighborlights += 1 end
	end
	return neighborlights
end

def getneighbors(coords)
	x, y = coords[0], coords[1]
	output = []
	output << [x+1, y+1]; output << [x+1, y]; output << [x+1, y-1]; output << [x, y-1]
	output << [x-1, y-1]; output << [x-1, y]; output << [x-1, y+1]; output << [x, y+1]
	return output
end

def isinbounds?(coords)
	x, y = coords[0], coords[1]
	if x < 0 then return false end; if x > ArrayMax then return false end
	if y < 0 then return false end; if y > ArrayMax then return false end
	return true
end

def getlight(lightarray, coords)
	x, y = coords[0], coords[1]
	if isinbounds?(coords)
		return lightarray[y][x]
	else
		return nil
	end
end

def countlights(lightarray)
	return lightarray.to_s.count("#")
end

def permanentlyon(lightarray)
	lightarray[0][0] = "#"; lightarray[0][-1] = "#"
	lightarray[-1][0] = "#"; lightarray[-1][-1] = "#"
	return lightarray
end

lightarray = Array.new
input.each do |line| lightarray << line.split("") end
ArrayMax = lightarray.length-1

100.times do
	newlightarray = Array.new
	for y in (0..ArrayMax)
		newrow = Array.new
		for x in (0..ArrayMax)
			state = getlight(lightarray, [x,y])
			neighborcount = countneighborlights(lightarray, [x,y])
			if (state == "#")
				if (neighborcount == 2) or (neighborcount == 3)
					newrow << state
				else
					newrow << "." 
				end
			else
				if (neighborcount == 3)
					newrow << "#" 
				else
					newrow << state
				end
			end
		end
		newlightarray << newrow
	end
	lightarray = permanentlyon(newlightarray)
end

outtoconsole countlights(lightarray)
