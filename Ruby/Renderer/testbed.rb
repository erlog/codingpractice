require_relative 'point'
require_relative 'bitmap'
require_relative 'utilities'
require_relative 'drawing'
require 'matrix'

def random_point()
    size = 128
    a = Point(rand(size), rand(size), rand(size)).to_f!
    b = Point(rand(size), rand(size), rand(size)).to_f!
    c = Point(rand(size), rand(size), rand(size)).to_f!
    return [a,b,c].sort
end

def test_tri()
    a,b,c = Point(103.0, 77.0, 43.0), Point(83.0, 10.0, 106.0), Point(81.0, 4.0, 97.0)
    return [a,b,c]
end

Start_Time = Time.now

verts = random_point
verts = test_tri
puts verts

bitmap = Bitmap.new(512, 512)
points = triangle(verts)
for bary in points
    pos = bary.from_barycentric(verts).round!
    bitmap.set_pixel(pos, White)
end
for point in verts
    bitmap.set_pixel(point, Pixel.new(255,0,255))
end
write_bitmap(bitmap)
