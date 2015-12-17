inputfile = open("Day003-input.txt")
input = inputfile.gets.strip.split("")

houses = Hash.new{0}
currentlocation = [0,0]
houses[currentlocation.to_s] += 1
input.each{|direction|
	case direction
		when "^" then currentlocation[1] += 1
		when ">" then currentlocation[0] += 1
		when "<" then currentlocation[0] += -1
		when "v" then currentlocation[1] += -1
	end

	houses[currentlocation.to_s] += 1
} 

puts houses.length

houses = Hash.new{0}
santalocation = [0,0]
robosantalocation = [0,0]

houses[santalocation.to_s] += 2

input.each_with_index{|direction, index|
	index.odd? ? currentlocation = santalocation : 
			currentlocation = robosantalocation
	case direction
		 when "^" then currentlocation[1] += 1
		 when ">" then currentlocation[0] += 1
		 when "<" then currentlocation[0] += -1
		 when "v" then currentlocation[1] += -1
	end
 
	houses[currentlocation.to_s] += 1

	index.odd? ? santalocation = currentlocation :
			robosantalocation = currentlocation
}

puts houses.length
