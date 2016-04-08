require_relative 'point'

BarycentricTriangle = [Point(1.0, 0, 0), Point(0, 1.0, 0), Point(0, 0, 1.0)]

def lerp(src, dest, amt)
    x = src.x + ( (dest.x - src.x) * amt )
    y = src.y + ( (dest.y - src.y) * amt )
    return Point(x, y)
end

def lerp_3d(src, dest, amt)
    x = src.x + ( (dest.x - src.x) * amt )
    y = src.y + ( (dest.y - src.y) * amt )
    z = src.z + ( (dest.z - src.z) * amt )
    return Point(x, y, z)
end

def amounts(segments)
    return (0..segments).map{ |n| n/segments }
end

def horizontal_line(src_x, dest_x, y)
    src_x, dest_x = [src_x, dest_x].sort
    points = []
    dest_x += 1
    while src_x < dest_x
        points << Point(src_x, y)
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
        bary = point.to_barycentric(a, b, c)
        next if (bary.x <= 0) or (bary.y <= 0) or  (bary.z <= 0)
        barys << bary
    end

    return barys
end

def triangle_area(a, b, c)
    #we only need these to compute a ratio so the final divide by 2 is not necessary
    return ( (a.x*b.y) + (b.x*c.y) + (c.x*a.y) - (a.y*b.x) - (b.y*c.x) - (c.y*a.x) )
end

def compute_triangle_d(verts)
    #for splitting any triangle into 2 flat-bottomed triangles
    a,b,c = verts
    dx = a.x + ( (b.y - a.y) / (c.y - a.y).to_f ) * (c.x - a.x)
    return Point(dx.to_i, b.y)
end


def half_triangle_positive(a, b, d)
    points = []
    y = b.y
    while y <= a.y
        left_x = compute_x(a, b, y)
        right_x = compute_x(a, d, y)
        points.concat(horizontal_line(left_x, right_x, y))
        y += 1
    end
    return points
end

def half_triangle_negative(b, c, d)
    points = []
    y = c.y
    while y <= b.y
        left_x = compute_x(c, b, y)
        right_x = compute_x(c, d, y)
        points.concat(horizontal_line(left_x, right_x, y))
        y += 1
    end
    return points
end

def compute_x(src, dest, y)
    #finds the x value for a given y value that lies between 2 points
    return dest.x if y == dest.y
    return src.x if y == src.y
    amt = (y - src.y)/(dest.y - src.y).to_f
    x = src.x + ( (dest.x - src.x) * amt ).round
    return x
end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2)
end

