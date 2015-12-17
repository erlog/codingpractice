cases = gets.strip.to_i

def arrayinit (length, data)
	myarray = Array.new(length)
	myarray.map! {|n| n = data}
	return myarray
end

for i in (0..cases-1)
	numberofdigits = gets.strip.to_i
	
	if numberofdigits < 3
		puts -1
		next
	end
	
	#check if we can fill it with fives
	if numberofdigits % 3 == 0
		puts arrayinit(numberofdigits, 5).join.to_i.to_s
		next
	end
	
	#okay, how many fives then?
	fives = (numberofdigits/3) * 3
	threes = numberofdigits - fives
	
	output = -1
	
	if (threes % 5) and (threes > 0) == 0
		output = (arrayinit(fives, 5) + arrayinit(threes, 3)).join.to_i.to_s
	end
	
	begin
		fives -= 3
		threes += 3
		if threes % 5 == 0
			output = (arrayinit(fives, 5) + arrayinit(threes, 3)).join.to_i.to_s
			break
		end
	end until fives <= 0
	
	puts output
end