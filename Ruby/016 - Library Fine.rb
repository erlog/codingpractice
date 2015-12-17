require 'date'

day, month, year = gets.strip.split(" ").map!{|s| s.to_i}
actualreturn = Date.new(year, month, day)
day, month, year = gets.strip.split(" ").map!{|s| s.to_i}
expectedreturn = Date.new(year, month, day)

if actualreturn.year > expectedreturn.year
	puts 10000
elsif (actualreturn.year == expectedreturn.year) and (actualreturn.month > expectedreturn.month)
	puts (actualreturn.month - expectedreturn.month) * 500
elsif (actualreturn.year == expectedreturn.year) and (actualreturn.month == expectedreturn.month) and (actualreturn.day > expectedreturn.day)
	puts (actualreturn.day - expectedreturn.day) * 15
else
	puts "0"
end
	
	


