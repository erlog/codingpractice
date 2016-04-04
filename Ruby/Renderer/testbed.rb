require_relative 'bitmap'
require_relative 'point'
#require_relative 'drawing'
#require_relative 'wavefront'
#require_relative 'matrix_math'
require_relative 'renderer'

Width = 512
Height = 512

def convert_barycentric(vertices, bary_coord)
    #unrolled for performance
    a,b,c = vertices
    x = (a.x * bary_coord.x) + (b.x * bary_coord.y) + (c.x * bary_coord.z)
    y = (a.y * bary_coord.x) + (b.y * bary_coord.y) + (c.y * bary_coord.z)
    z = (a.z * bary_coord.x) + (b.z * bary_coord.y) + (c.z * bary_coord.z)
    return Point(x, y, z)
end

def line_length(src, dest)
    return Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2).to_i
end

def new_triangle(triangle)
    a,b,c = triangle
    min_x = [a.x, b.x, c.x].min
    max_x = [a.x, b.x, c.x].max

end

def triangle(resolution)
    a, b, c = ReferenceTriangle
    #return [a, b, c]                            #for vertex cloud
    left = line(a, b, resolution)
    right = line(a, c, resolution)
    bottom = line(b, c, resolution)
    #return left + right + bottom                #for wireframe
    filler = []
    filler.concat(left)
    filler.concat(right)
    filler.concat(bottom)

    for point in bottom
        filler.concat(line_middle(a, point, resolution))
    end
    for point in left
        filler.concat(line_middle(c, point, resolution))
    end
    for point in right
        filler.concat(line_middle(b, point, resolution))
    end

    return filler
end

def random_tri(width, height)
    return [ Point(rand(width), rand(height)),
             Point(rand(width), rand(height)),
             Point(rand(width), rand(height)) ]
end

bitmap = Bitmap.new(Width, Height)
coords = new_triangle(random_tri(Width, Height))

drawn_pixels = 0
coords.each do |coord|
    bitmap.set_pixel(coord, White)
    drawn_pixels += 1
end
log(drawn_pixels.to_s)
log(coords.length.to_s)
write_bitmap(bitmap)



