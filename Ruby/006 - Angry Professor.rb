cases = gets.strip.to_i

def ontime(time)
	if time <= 0
		return 1
	else
		return 0
	end
end

for i in (0..cases-1)
	ontimecount = 0

    students, threshold = gets.strip.split(" ")
    students = students.to_i
	threshold = threshold.to_i
	times = gets.strip.split(" ")
	times.map! {|time| time.to_i}
	times.map! {|time| ontimecount += ontime(time)}
	
	if ontimecount < threshold
		puts "YES"
	else
		puts "NO"
	end
	
end