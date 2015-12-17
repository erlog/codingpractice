puts gets.downcase.gsub(/[^a-z]/, "").split("").uniq.count == 26 ? "pangram" : "not pangram"



