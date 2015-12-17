
def maxadjacent(grid, x, y)
	left = grid[x-1][y].to_i
	right = grid[x+1][y].to_i
	up = grid[x][y+1].to_i
	down = grid[x][y-1].to_i
	return [left, right, up, down].max
end

rowcount = gets.strip.to_i
#rowcount = 8
grid = Array.new()
rowcount.times do
	grid << gets.strip
	#grid = "63456754\n68335522\n25482912\n54429472\n35416147\n75848666\n41633675\n82511989".split("\n")
end

xlocations = Array.new()
for y in (1..rowcount-2)
	for x in (1..rowcount-2)
		xlocations << [x, y] if grid[x][y].to_i > maxadjacent(grid, x, y)
	end
end

xlocations.each {|pos| grid[pos[0]][pos[1]] = "X"}
puts grid

	
	


