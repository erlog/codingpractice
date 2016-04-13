require_relative 'point'
require_relative 'bitmap'
require_relative 'utilities'
require_relative 'drawing'
require_relative 'matrix_math'
require 'matrix'

width = 384
height = 384
screen_center = PointObject.new((width/2)-1, (height/2)-1, 255)

def random_tri(size)
    a = PointObject.new(rand(size), rand(size), rand(size))
    b = PointObject.new(rand(size), rand(size), rand(size))
    c = PointObject.new(rand(size), rand(size), rand(size))
    return [a,b,c].sort
end

def test_tri()
    a,b,c = PointObject.new(0, 0, 0), PointObject.new(196, 196, 0), PointObject.new(196, 0, 0)
    return [a,b,c].sort
end

Start_Time = Time.now
bitmap_a = Bitmap.new(width, height)
bitmap_b = Bitmap.new(width, height)

verts = test_tri
#verts = random_tri(383)
points = triangle(verts)
a,b,c = verts

for bary in points
    pos = barycentric_to_cartesian(bary, verts).round!
    bitmap_a.set_pixel(pos, White)
end

for point in verts
    bitmap_a.set_pixel(point, Pixel.new(255,0,255))
end

puts points.length
puts triangle_area(a, b, c).abs/2.0
puts line_length(a, b)
puts line_length(b, c)
puts line_length(a, c)

write_bitmap(bitmap_a)

