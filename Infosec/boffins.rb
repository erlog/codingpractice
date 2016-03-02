input = open("boffins.txt").readlines

characters = ("a".."z").to_a + ("0".."9").to_a

input.each do |line|
    line.split(" ").each do |word|
        offset = -1 * word.length
        word.split("").each do |char|
            index = characters.index(char)
            index = 36 - index if index < 0
            print characters[index + offset]
        end
        print " "
    end
    print "\n"
end
