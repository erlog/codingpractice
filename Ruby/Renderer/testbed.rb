require_relative 'point'
require_relative 'bitmap'
require 'matrix'

ReferenceTriangle = [Point(1, 0, 0), Point(0, 1, 0), Point(0, 0, 1)]

def convert_barycentric(vertices, bary_coord)
    #unrolled for performance
    a,b,c = vertices
    x = (a.x * bary_coord.x) + (b.x * bary_coord.y) + (c.x * bary_coord.z)
    y = (a.y * bary_coord.x) + (b.y * bary_coord.y) + (c.y * bary_coord.z)
    z = (a.z * bary_coord.x) + (b.z * bary_coord.y) + (c.z * bary_coord.z)
    return Point(x, y, z)
end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2)
end

def amounts(segments)
    amounts = (0..segments).map{ |n| n.to_f/segments }
end

def triangle_area(verts)
    a,b,c = verts
    return  (a.x * (b.y - c.y)) + (b.x * (c.y - a.y)) + (c.x * (a.y - b.y))
end

def lerp(src, dest, amt)
    #unrolled for performance
    x = src.x + ( (dest.x - src.x) * amt )
    y = src.y + ( (dest.y - src.y) * amt )
    z = src.z + ( (dest.z - src.z) * amt )
    return Point(x, y, z)
end

def line(src, dest)
    segments = line_length(src, dest)
    x_per_segment = (dest.x - src.x)/segments
    y_per_segment = (dest.y - src.y)/segments

    points = [dest]
    x = src.x; y = src.y
    n = 0
    while n < segments
        points << Point(x.ceil, y.ceil)
        x += x_per_segment
        y += y_per_segment
        n += 1
    end
    return points.uniq
end

def triangle(verts)
    a,b,c = verts
    points = []
    line_a = line(a,b)
    for point in line_a
        points.concat(line(point, c))
    end
    return points
end

verts = [Point(25, 25, 0), Point(125, 25, 0), Point(25, 125, 0)]

points = triangle(verts)
puts points.length
puts triangle_area(verts)/2

bitmap = Bitmap.new(200, 200)
for point in points
    bitmap.set_pixel(point, White)
end
bitmap.writetofile("test.bmp")
