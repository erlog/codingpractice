def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def write_bitmap(bitmap)
        bitmap.writetofile("output/renderer - " + Time.now.to_s[0..-7] + ".bmp")
end
