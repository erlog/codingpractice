cases = gets.strip.to_i

for i in (0..cases-1)
	number = gets.strip.to_i
	digits = number.to_s.split("")
	count = 0
	digits.each {|digit| count += 1 if digit != "0" and number % digit.to_i == 0}
	puts count
end
