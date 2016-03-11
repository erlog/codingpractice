require_relative 'bitmap'

def lerp(src, dest, amt)
    return src + ( (dest - src) * amt )
end

def line(src, dest)
    points = [src]
    length = Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2).to_i
    (0..length).each do |n|
        amt = n.to_f/length
        x, y = lerp(src.x, dest.x, amt).to_i, lerp(src.y, dest.y, amt).to_i
        points << Point(x, y)
    end
    points << dest
    return points
end

mybmp = Bitmap.new(100, 100)

line(Point(0, 0), Point(25, 50)).each do |point|
    mybmp.setpixel(point, "FFFFFF")
end


mybmp.writetofile("renderer - " + Time.now.to_s[0..-7] + ".bmp")
