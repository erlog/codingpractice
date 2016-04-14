require_relative 'point'

BarycentricTriangle = [ Point.new([1.0, 0.0, 0.0]),
                        Point.new([0.0, 1.0, 0.0]),
                        Point.new([0.0, 0.0, 1.0]) ]

def lerp(src, dest, amt)
    x = src.xyz[0] + ( (dest.xyz[0] - src.xyz[0]) * amt )
    y = src.xyz[1] + ( (dest.xyz[1] - src.xyz[1]) * amt )
    return Point.new([x, y, 1])
end

def lerp_3d(src, dest, amt)
    x = src.xyz[0] + ( (dest.xyz[0] - src.xyz[0]) * amt )
    y = src.xyz[1] + ( (dest.xyz[1] - src.xyz[1]) * amt )
    z = src.xyz[2] + ( (dest.xyz[2] - src.xyz[2]) * amt )
    return Point.new([x, y, z])
end

def amounts(segments)
    return (0..segments).map{ |n| n/segments }
end

def horizontal_line(src_x, dest_x, y)
    src_x, dest_x = [src_x, dest_x].sort
    points = []
    dest_x += 1
    while src_x < dest_x
        points << Point.new([src_x, y, 1])
        src_x += 1
    end
    return points
end

def line_middle(src, dest)
    segments = line_length(src, dest).ceil.to_f

    points = []
    n = 1
    while n < segments
        amt = n/segments
        points << lerp(src, dest, amt)
        n += 1
    end

    return points
end

def barycentric_line_middle(src, dest, length)
    points = []
    for n in (1..length-1)
        amt = n/length
        points << lerp_3d(src, dest, amt)
    end

    return points
end

def barycentric_wireframe(a, b, c)
    bary_a, bary_b, bary_c = BarycentricTriangle
    points = [bary_a, bary_b, bary_c]

    left_length = line_length(a, b).ceil.to_f
    points.concat(barycentric_line_middle(bary_a, bary_b, left_length))
    right_length = line_length(a, c).ceil.to_f
    points.concat(barycentric_line_middle(bary_a, bary_c, right_length))
    bottom_length = line_length(b, c).ceil.to_f
    points.concat(barycentric_line_middle(bary_b, bary_c, bottom_length))

    return points
end

def triangle(verts)
    a,b,c = verts

    wireframe_points = [a,b,c]
    fill_points = []

    #paint outline
    barys = barycentric_wireframe(a, b, c)
    return barys if triangle_area(a, b, c) == 0 #points are colinear


    #fill triangle
    d = compute_triangle_d(verts)
    #paint top half
    fill_points.concat(half_triangle_positive(a, b, d))
    #paint bottom half
    fill_points.concat(half_triangle_negative(b, c, d))

    for point in fill_points
        bary = cartesian_to_barycentric!(point, verts)
        next if (bary.xyz[0] <= 0) or (bary.xyz[1] <= 0) or  (bary.xyz[2] <= 0)
        barys << bary
    end

    return barys
end

def triangle_area(a, b, c)
    #we only need these to compute a ratio so the final divide by 2 is not necessary
    return ( (a.xyz[0]*b.xyz[1]) + (b.xyz[0]*c.xyz[1]) + (c.xyz[0]*a.xyz[1]) - (a.xyz[1]*b.xyz[0]) - (b.xyz[1]*c.xyz[0]) - (c.xyz[1]*a.xyz[0]) )
end

def compute_triangle_d(verts)
    #for splitting any triangle into 2 flat-bottomed triangles
    a,b,c = verts
    dx = a.xyz[0] + ( (b.xyz[1] - a.xyz[1]) / (c.xyz[1] - a.xyz[1]).to_f ) * (c.xyz[0] - a.xyz[0])
    return Point.new([dx.to_i, b.xyz[1], 1])
end


def half_triangle_positive(a, b, d)
    points = []
    y = b.xyz[1]
    while y <= a.xyz[1]
        left_x = compute_x(a, b, y)
        right_x = compute_x(a, d, y)
        points.concat(horizontal_line(left_x, right_x, y))
        y += 1
    end
    return points
end

def half_triangle_negative(b, c, d)
    points = []
    y = c.xyz[1]
    while y <= b.xyz[1]
        left_x = compute_x(c, b, y)
        right_x = compute_x(c, d, y)
        points.concat(horizontal_line(left_x, right_x, y))
        y += 1
    end
    return points
end

def compute_x(src, dest, y)
    #finds the x value for a given y value that lies between 2 points
    return dest.xyz[0] if y == dest.xyz[1]
    return src.xyz[0] if y == src.xyz[1]
    amt = (y - src.xyz[1])/(dest.xyz[1] - src.xyz[1]).to_f
    x = src.xyz[0] + ( (dest.xyz[0] - src.xyz[0]) * amt ).round
    return x
end

def line_length(src, dest)
    return Math.sqrt((dest.xyz[0] - src.xyz[0])**2 + (dest.xyz[1] - src.xyz[1])**2)
end

