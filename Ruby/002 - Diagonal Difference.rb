length = 3
diagarray = [[11, 2, 4], [4, 5, 6], [10, 8, -12]]

updown = 0
downup = 0

for i in (0..length-1)
	updown += diagarray[i][i]
	downup += diagarray[length-i-1][i]
end

print (updown-downup).abs
