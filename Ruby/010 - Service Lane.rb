cases = gets.strip.split(" ")[1].to_i
widths = gets.strip.split(" ").map! {|n| n.to_i}

for i in (0..cases-1)
	input = gets.strip.split(" ").map! {|n| n.to_i}
	entrance = input[0]
	exit = input[1]
	puts widths[entrance..exit].min
end
