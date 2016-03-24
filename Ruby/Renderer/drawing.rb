ReferenceTriangle = [Point(1, 0, 0), Point(0, 1, 0), Point(0, 0, 1)]

def lerp(src, dest, amt)
    #unrolled for performance
    x = src.x + ( (dest.x - src.x) * amt )
    y = src.y + ( (dest.y - src.y) * amt )
    z = src.z + ( (dest.z - src.z) * amt )
    return Point(x, y, z)
end

def convert_barycentric(vertices, bary_coord)
    #unrolled for performance
    a,b,c = vertices
    x = (a.x * bary_coord.x) + (b.x * bary_coord.y) + (c.x * bary_coord.z)
    y = (a.y * bary_coord.x) + (b.y * bary_coord.y) + (c.y * bary_coord.z)
    z = (a.z * bary_coord.x) + (b.z * bary_coord.y) + (c.z * bary_coord.z)
    return Point(x, y, z)
end

def triangle(resolution)
    a, b, c = ReferenceTriangle
    #return [a, b, c]                            #for vertex cloud
    left = line(a, b, resolution)
    right = line(a, c, resolution)
    bottom = line(b, c, resolution)
    #return left + right + bottom                #for wireframe
    filler = []
    bottom.each do |point|
        filler += line_middle(a, point, resolution)
    end
    left.each do |point|
        filler += line_middle(c, point, resolution)
    end
    right.each do |point|
        filler += line_middle(b, point, resolution)
    end
    points = left + right + bottom + filler
    return points
end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2)
end

def compute_triangle_resolution(face, screen_center)
    a, b, c = face.map(&:v).map{ |point| point.to_screen(screen_center) }
    one = line_length(a, b).to_i
    two = line_length(b, c).to_i
    three = line_length(a, c).to_i
    return [one, two, three].max
end

def line(src, dest, segments)
    points = [src, dest]

    points += line_middle(src, dest, segments)

    return points
end

def line_middle(src, dest, segments)
    points = []
    (1..segments-1).each do |n|
        amt = n.to_f/segments
        point = lerp(src, dest, amt)
        points << point
    end
    return points
end
