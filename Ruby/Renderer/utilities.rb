def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def write_bitmap(bitmap)
        bitmap.writetofile("output/renderer - " + Time.now.to_s[0..-7] + ".bmp")
end

def clamp(value, min, max)
    return min if value < min
    return max if value > max
    return value
end

def color_multiply(rgb, factor)
    r = clamp(rgb[0]*factor, 0, 255)
    g = clamp(rgb[1]*factor, 0, 255)
    b = clamp(rgb[2]*factor, 0, 255)
    return [r,g,b]
end
