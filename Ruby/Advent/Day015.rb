input = open("Day015-input.txt").readlines.map!(&:strip)

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

def bakecookie(amounts)
	bakedproperties = [0,0,0,0,0]
	IngredientNames.zip(amounts).each{ |name, amount|
		bakedproperties = addarrays(bakedproperties, Ingredients[name].map{|x| x*amount})
	}
	return bakedproperties
end

def scorecookie(properties)
	score = 1
	properties.each do |x|
		if x < 0
			return 0
		else
			score *= x
		end
	end
	return score
end

def addarrays(array1, array2)
	output = Array.new
	array1.zip(array2).each{ |array1item, array2item|
		output << array1item + array2item
	}
	return output
end

def randomingredients
	ingredients = Array.new
	ingredients << rand(101)
	ingredients << rand(101-ingredients.inject(:+))
	ingredients << rand(101-ingredients.inject(:+))
	ingredients << 100-ingredients.inject(:+)
	return ingredients
end

Ingredients = Hash.new

for line in input
	line = line.delete(":").delete(",").split.reverse
	ingredientname = line.pop
	characteristics = Array.new
	5.times do 
		line.pop
		characteristics << line.pop.to_i
	end
	Ingredients[ingredientname] = characteristics
end

IngredientNames = Ingredients.keys.sort

maxscore = 0
1000000.times do
	properties = bakecookie(randomingredients())
	calories = properties.pop
	score = scorecookie(properties)
	if calories == 500
		maxscore = score unless (score < maxscore)
	end
end

outtoconsole maxscore
