input = open("boffins2-original.txt").read

whitespace = ["\n", " "]
characters = open("codewheel.txt").readlines.map!(&:strip)
puts characters.to_s

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

(0..0).each do |linenumber|
    plaintext = []
    input.split("\n").each do |line|
        linelength = line.length + line.scan(/\. /).count
        linelength = linelength % 10
        plaintext << "#{linelength.to_s.rjust(2,"0")}: "
        line.split(" ").each do |word|
            offset = linelength + word.length
            word.split("").each do |char|
                if !whitespace.include?(char) and characters.include?(char)
                    index = characters.index(char)
                    index = index - offset
                    plaintext << characters[index]
                else
                    plaintext << char
                end
            end
            plaintext << " "
        end
        plaintext << "\n"
    end
    puts plaintext.join("")
end

puts "---"
char_freq = freq(input.split(""))
outdict(char_freq, 100)
print char_freq.keys.to_a.sort


