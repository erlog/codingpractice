input = "12:45:54PM"

ampm = input[-2..-1]
input = input[0..-3].split(":")

if ampm == "PM"
	input[0] = input[0].to_i
	if input[0] < 12
		input[0] += 12
	end
	input[0] = input[0].to_s
else
    if input[0] == "12"
		input[0] = "00"
	end
end

print input.join(":")


	
