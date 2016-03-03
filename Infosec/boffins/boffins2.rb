def addchar(char, offset)
    return (char.bytes.pop + offset).chr
end

def freq(list)
    dict = Hash.new(0)
    list.map!(&:strip).reject!(&:empty?)
    list.each do |item|
        dict[item] += 1
    end

    total = list.length.to_f
    dict.each do |key, value|
        dict[key] = (value / total)*100
    end
    return dict
end

def outdict(dict, maxitems)
    dict.sort_by{ |key, value| value}.reverse[0..maxitems].each do |item, count|
        puts item.to_s + ": " + count.to_s
    end
end

input = open("boffins2.txt").read

whitespace = ["\n", " "]
characters = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
    "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "<", ">", "?", ",",
    ".", "/", ";", "'", ":", "\"", "{", "}", "|", "[", "]", "\\", "-", "=",
    "_", "+", "`", "~", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")" ]

plaintext = []
input.split("\n").each do |line|
    linelength = line.length
    linelength = linelength % 10 if linelength > 10
    line.split(" ").each do |word|
        offset = linelength + word.length
        word.split("").each do |char|
            if !whitespace.include?(char)
                plaintext << characters[characters.index(char) - offset]
            else
                plaintext << char
            end
        end
        plaintext << " "
    end
    plaintext << "\n"
end

puts plaintext.join(""); puts
puts "Key:"; puts characters.to_s
