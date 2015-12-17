input = open("Day016-input.txt").readlines.map!(&:strip)

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

def returnsubset(label, value, data)
	datasubset = Hash.new
	data.each do |key, entity|
		if !entity.has_key?(label) | (entity[label] == value)
			datasubset[key] = entity 
		end
	end
	return datasubset
end

def returnsubsetgreater(label, value, data)
	datasubset = Hash.new
	data.each do |key, entity|
		if !entity.has_key?(label)
			datasubset[key] = entity 
		elsif (entity[label] > value)
			datasubset[key] = entity 
		end
	end
	return datasubset
end

def returnsubsetlesser(label, value, data)
	datasubset = Hash.new
	data.each do |key, entity|
		if !entity.has_key?(label)
			datasubset[key] = entity 
		elsif (entity[label] < value)
			datasubset[key] = entity 
		end
	end
	return datasubset
end

auntdata = Hash.new

for line in input
	line = line.gsub(":","").gsub(",","").split[1..-1]
	aunt = line[0]
	data = Hash.new
	items = line[1..-1].each_slice(2).to_a
	items.each{|item| data[item[0]] = item[1].to_i}
	auntdata[aunt] = data 
end

auntdata = returnsubset("children", 3, auntdata)
auntdata = returnsubsetgreater("cats", 7, auntdata)
auntdata = returnsubset("samoyeds", 2, auntdata)
auntdata = returnsubsetlesser("pomeranians", 3, auntdata)
auntdata = returnsubset("akitas", 0, auntdata)

auntdata = returnsubset("vizslas", 0, auntdata)
auntdata = returnsubsetlesser("goldfish", 5, auntdata)
auntdata = returnsubsetgreater("trees", 3, auntdata)
auntdata = returnsubset("cars", 2, auntdata)
auntdata = returnsubset("perfumes", 1, auntdata)

outtoconsole auntdata

