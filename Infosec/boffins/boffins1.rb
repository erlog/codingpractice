def addchar(char, offset)
    return (char.bytes.pop + offset).chr
end

def freq(list)
    dict = Hash.new(0)
    list.map!(&:strip).reject!(&:empty?)
    list.each do |item|
        dict[item] += 1
    end

    return dict

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

def sortdictkeysbyvalue(dict)
    keys = []
    dict.sort_by{ |key, value| value}.reverse.each do |item, count|
        keys << item
    end
    return keys
end

UPPERCASE = ("A".."Z").to_a
LOWERCASE = ("a".."z").to_a

lines = open("boffins1.txt").readlines.map!(&:strip)
text = lines.join("")
inputchars = lines.join("").split("")

#rotate ciphertext
chars = []
(0..49).each do |index|
    lines.each do |line|
        chars << line[index]
    end
end

slices = chars.each_slice(5).map{ |slc| slc.join("") }

strips = []
(0..4).each do |x|
    strips << slices.map{ |slc| slc[x] }.join
end

CHARFREQ = "etaoinshrdlcumwfgypbvkjxqz"
#CHARFREQ = ("a".."z").to_a.join

decodedstrips = []
strips.each do |strip|
    decoded = []
    key = sortdictkeysbyvalue(freq(strip.chars)).join
    strip.chars.each do |char|
        index = key.index(char)
        decoded << CHARFREQ[index]
    end
    decodedstrips << decoded.join
end

decodedstrips.each do |strip|
   puts strip.chars.each_slice(28).map(&:join)
end
