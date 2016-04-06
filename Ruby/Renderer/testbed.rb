require_relative 'point'
require_relative 'bitmap'
require_relative 'utilities'
require_relative 'drawing'
require_relative 'matrix_math'
require 'matrix'

width = 384
height = 384

def random_point()
    size = 128
    a = Point(rand(size), rand(size), rand(size)).to_f!
    b = Point(rand(size), rand(size), rand(size)).to_f!
    c = Point(rand(size), rand(size), rand(size)).to_f!
    return [a,b,c].sort
end

def test_tri()
    a,b,c = Point(0, 0, 0), Point(1, 0, 0), Point(0, 1, 0)
    return [a,b,c].sort
end

Start_Time = Time.now
bitmap = Bitmap.new(width, height)

verts = random_point
verts = test_tri
a,b,c = verts
puts verts

screen_center = Point((width/2)-1, (height/2)-1, 255)
verts = verts.map{ |vert| vert.to_screen!(screen_center) }
points = triangle(verts)

for bary in points
    pos = bary.from_barycentric(verts).round!
    bitmap.set_pixel(pos, White)
end
puts points.length
puts line_length(a, b)
puts line_length(b, c)
puts line_length(a, c)
for point in verts
    bitmap.set_pixel(point, Pixel.new(255,0,255))
end

write_bitmap(bitmap)


