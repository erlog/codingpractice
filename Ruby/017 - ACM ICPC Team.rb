$TESTING = true
$StartTime = Time.new()
$testinput = File.open('testinput.txt') if $TESTING
def getinput	
	return $TESTING ? $testinput.readline : gets
end

def checkpoint(output)
	puts output + " " + (Time.new() - $StartTime).to_s if $TESTING
end

peoplecount, topicscount = getinput.strip.split(" ").map! {|s| s.to_i}
people = Array.new()

peoplecount.times do
	people << getinput.strip.to_i(2)
end

def totaltopics(firstset, secondset)
	return (firstset | secondset).to_s(2).count("1")
end

cache = Array.new()
for personx in people
	for persony in people
		cache << totaltopics(personx, persony)
	end
end

bestcount = cache.max
puts bestcount
puts cache.count(bestcount)/2
checkpoint("Finished: ")





