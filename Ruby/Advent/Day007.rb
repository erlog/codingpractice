input = open("Day007-input.txt").readlines.map!(&:strip)

Commands = Hash.new{[]}
Registers = Hash.new

def notgate(value)
	value = 65535 - value
	return value
end

def lshiftgate(value, amount)
	value = value << amount
	return value
end

def rshiftgate(value, amount)
	value = value >> amount
	return value
end

def andgate(first, second)
	value = first & second
	return value
end

def orgate(first, second)
	value = first | second 
	return value
end

def getregister(register)
	if register.match(/\d/)
		return register.to_i
	elsif Registers[register]
		return Registers[register]
	else
		processoutput =  processcalls(register)
		setregister(register, processoutput)
		return Registers[register]
	end
end

def setregister(register, value)
	Registers[register] = value.to_i
end

def processcalls(register)
	commands = Commands[register]
	for command in commands
		if command.length == 1
			return getregister(command[0])
		elsif command[0] == "NOT"
			value = getregister(command[1])
			return notgate(value)
		elsif command[1] == "AND"
			left,right = getregister(command[0]), getregister(command[2]) 
			return andgate(left, right)
		elsif command[1] == "OR"
			left,right = getregister(command[0]), getregister(command[2]) 
			return orgate(left, right)
		elsif command[1] == "LSHIFT"
			left,right = getregister(command[0]), getregister(command[2]) 
			return lshiftgate(left, right)
		elsif command[1] == "RSHIFT"
			left,right = getregister(command[0]), getregister(command[2]) 
			return rshiftgate(left, right)
		end
	end
end

for command in input
	command = command.strip.split("->").map!(&:strip)
	destinationregister = command[1]
	command = command[0].split.map!(&:strip)	
	Commands[destinationregister] = Commands[destinationregister] << command
end

#start from a and then use recursion to solve
partone = processcalls("a")
print "Part 1: " + partone.to_s 
Registers.clear
Registers["b"] = partone
parttwo = processcalls("a")
print " Part 2: " + parttwo.to_s 

