def lerp(src, dest, amt)
    return src if amt == 0
    return src + ( (dest - src) * Point(amt, amt, amt) )
end

def triangle(vertices, resolution)
    a, b, c = vertices
    left = line(a, b, resolution)
    right = line(a, c, resolution)
    bottom = line(b, c, resolution)

    filler = []
    bottom.each do |point|
        filler += line(a, point, resolution)
    end
    left.each do |point|
        filler += line(c, point, resolution)
    end
    right.each do |point|
        filler += line(b, point, resolution)
    end
    return left + right + bottom + filler

end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2)
end

def compute_triangle_resolution(vertices)
    a, b, c = vertices
    one = line_length(a, b).to_i
    two = line_length(b, c).to_i
    three = line_length(a, c).to_i
    return [one, two, three].max
end

def line(src, dest, length)
    points = []

    (0..length).each do |n|
        amt = n.to_f/length
        point = lerp(src, dest, amt)
        points << point
    end

    return points
end
