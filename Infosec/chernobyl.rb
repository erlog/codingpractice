words = open("/home/jroze/Downloads/sowpods.txt").readlines.map!(&:strip)

def hash(string)
    r15 = 0
    string.bytes.each do |byte|
        r13 = byte + r15

        r15 = r13
        5.times do r15 += r15 end
        r15 -= r13

        r15 = r15 & 0xFFFF
    end
    return r15.to_s(16)
end

dict = Hash.new([])
words.each do |word|
        wordhash = hash(word)
        dict[wordhash] += [word]
end

puts dict.keys.length

output = []
dict.keys.each do |key|
    if dict[key].length > 10
        output << key + ": " + dict[key].sort_by!(&:length).to_s
    end
end

open("/home/jroze/Downloads/collisions.txt", "w").write(output.sort.join("\n"))
