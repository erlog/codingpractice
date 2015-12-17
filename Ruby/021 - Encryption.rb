inputstring = gets.strip.delete(" ")
#inputstring = "if man was meant to stay on the ground god would have given us roots".delete(" ")

dimensions = (inputstring.length ** 0.5).ceil
padding = (dimensions**2) - inputstring.length
inputstring += " " * padding 

characterarray = inputstring.split("").each_slice(dimensions).to_a
characterarray = characterarray.transpose
characterarray.map! do |line| line.join("").strip end

puts characterarray.join(" ")
