keyword = "SECRET"
keyword = keyword.split("").uniq
alphabet = ("A".."Z").to_a
keycharacters = (keyword + alphabet).uniq.each_slice(keyword.length).to_a
keystring = ""

index = 0
keycharacters[0].length.times do
	keystring += keycharacters.map{|row| row[index]}.join("")
	index += 1
end

print keystring

