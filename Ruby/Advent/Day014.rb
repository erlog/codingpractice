input = open("Day014-input.txt").readlines.map!(&:strip).map!(&:split)

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

def calculatedistance(speed, timelimit, resttime, totaltime)
	cycledistance = speed * timelimit
	cycletime = timelimit + resttime
	numberofcycles = totaltime / cycletime
	remainingtime = totaltime % cycletime

		distance = numberofcycles * cycledistance
	(remainingtime >= timelimit) ?
		(distance += cycledistance) :
			distance += (remainingtime * speed)

	return distance
end

#outtoconsole calculatedistance(14, 10, 127, 1000)
#outtoconsole calculatedistance(16, 11, 162, 1000)

finishtime = 2503
leaderboard = Hash.new{0}

for i in (1..2502)
	distances = Hash.new
	for line in input
		name, speed, timelimit, resttime =
			line[0], line[3].to_i, line[6].to_i, line[13].to_i
		distance = calculatedistance(speed, timelimit, resttime, i)
		distances[name] = distance
	end

	winners = distances.select{ |key, value| value == distances.values.max }.keys
	winners.each{|winner| leaderboard[winner] += 1}
end

outtoconsole leaderboard
