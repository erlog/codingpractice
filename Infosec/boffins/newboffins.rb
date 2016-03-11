plainlines = open("newboffins.txt").readlines.map(&:strip)

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

    return dict.sort_by{ |key, value| value }.reverse
end

LetterFrequency = "etaoinshrdlcumwfgypbvkjxqz"

alpha = LetterFrequency.chars.zip(LetterFrequency.upcase.chars).flatten
numeric = ("0".."9").to_a
Key = numeric + alpha
puts Key.join

prevwordlength = plainlines[-1].split(" ")[-1].length

ciphertext = []
plainlines.each do |line|
    line.split(" ").each do |word|
        word.chars.each do |char|
            index = Key.index(char)
            if index
                index -= prevwordlength
                ciphertext << Key[index]
            else
                ciphertext << char
            end
        end
        ciphertext << Key[-1*prevwordlength]
        prevwordlength = word.length
    end
    ciphertext.pop
    ciphertext << "\n\n"
end

puts ciphertext.join

charfreq = freq(ciphertext)
charfreq.map{ |x| print x; puts}
puts plainlines
charfreq = freq(plainlines.flatten.join.split(""))
charfreq.map{ |x| print x; puts}
