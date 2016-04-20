require_relative 'point'
require_relative 'bitmap'
require_relative 'utilities'
require_relative 'matrix_math'
require 'matrix'
require_relative 'c_optimization'; include C_Optimization

width = 384
height = 384
screen_center = Point.new((width/2)-1, (height/2)-1, 255)

test = Z_Buffer.new(width, height);
puts test.should_draw?(Point.new(100.0, 100.0, 1337.0));
puts test.should_draw?(Point.new(100.0, 100.0, 1225.0));
puts test.should_draw?(Point.new(100.0, 100.0, 1449.0));
exit

def random_tri(size)
    a = Point.new(rand(size), rand(size), rand(size))
    b = Point.new(rand(size), rand(size), rand(size))
    c = Point.new(rand(size), rand(size), rand(size))
    return [a,b,c].sort
end

def test_tri()
    a,b,c = Point.new(0, 0, 0), Point.new(196, 196, 0), Point.new(196, 0, 0)
    return [a,b,c].sort
end

Start_Time = Time.now
bitmap_a = Bitmap.new(width, height)
bitmap_b = Bitmap.new(width, height)

#verts = test_tri
verts = random_tri(383)
drawn = 0
a,b,c = verts

triangle(verts){ |bary|
    pos = bary.to_cartesian(verts).round!
    bitmap_a.set_pixel(pos, White)
    drawn += 1
}

for point in verts
    bitmap_a.set_pixel(point, Pixel.new(255,0,255))
end
write_bitmap(bitmap_a)
