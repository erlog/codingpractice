require_relative 'bitmap'
require_relative 'point'
require_relative 'wavefront'

Width = 512
Height = 512

def lerp(src, dest, amt)
    return src + ( (dest - src) * amt )
end

def triangle(a, b, c)
    left = line(a, b)
    right = line(a, c)
    bottom = line(b, c)
    filler = []
    bottom.each do |point|
        filler += line(a, point)
    end
    left.each do |point|
        filler += line(c, point)
    end
    right.each do |point|
        filler += line(b, point)
    end
    return left + right + bottom + filler
end

def line(src, dest)
    #this line algo is pretty lol
    points = [src.to_i, dest.to_i]
    length = Math.sqrt((dest.x - src.x)**2 + (dest.y - src.y)**2).to_i
    return points if length == 0
    (0..length).each do |n|
        amt = n.to_f/length
        x, y = lerp(src.x, dest.x, amt).to_i, lerp(src.y, dest.y, amt).to_i
        points << Point(x, y)
    end
    return points
end

def render_model(filename, width = Width, height = Height)
    center = Point((Width/2) - 1, (Height/2) - 1)
    object = Wavefront.new(filename)
    bitmap = Bitmap.new(width, height)

    object.triangles.each do |vertex_ids|
        a, b, c = vertex_ids.map!{ |id| center - (object.vertices[id] * center) }
        bitmap.setpixels(triangle(a, b, c), rand(1<<24).to_s(16))
    end
    bitmap.writetofile("renderer - " + filename + " - " + Time.now.to_s[0..-7] + ".bmp")
end

render_model("wt_teapot.obj")
render_model("african_head.obj")

