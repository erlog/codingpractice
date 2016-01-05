
def finddivisors(number)
	divisors = [number, 1]
	(2..(number*0.5)+1).each do |try|
		if (number % try == 0)
			divisors << try
		end
	end
	return divisors
end

def filterdivisors(divisors)
	filtered = []
	divisors.each do |divisor| filtered << divisor unless (divisor 

puts (finddivisors(ARGV[0].to_i))
