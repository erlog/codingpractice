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
    filler.concat(bottom)
    for point in bottom
        filler.concat(line_middle(a, point, resolution))
    end
    filler.concat(left)
    for point in left
        filler.concat(line_middle(c, point, resolution))
    end
    filler.concat(right)
    for point in right
        filler.concat(line_middle(b, point, resolution))
    end

    return filler
end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2).to_i
end

def compute_triangle_resolution(face, screen_center)
    a, b, c = face.map(&:v).map{ |point| point.to_screen(screen_center) }
    one = line_length(a, b)
    two = line_length(b, c)
    three = line_length(a, c)
    return [one, two, three].max.to_f
end

def line(src, dest, segments)
    points = [src, dest]

    points.concat(line_middle(src, dest, segments))

    return points
end

def line_middle(src, dest, segments)
    points = []
    n = segments - 1
    while n > 0
        amt = n/segments
        point = lerp(src, dest, amt)
        points << point
        n -= 1
    end
    return points
end
