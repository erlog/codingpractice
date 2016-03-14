require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'

Width = 512
Height = 512

def render_model(filename, width = Width, height = Height)
    center = Point((width/2) - 1, (height/2) - 1)
    object = Wavefront.new(filename)
    bitmap = Bitmap.new(width, height)
    light_direction = Point(0, 0, -1)


    object.triangles.each do |vertex_ids|
        a, b, c = vertex_ids.map{ |id| object.vertices[id] }
        normal = (c - a).cross_product(b - a).normalize
        intensity = normal.scalar_product(light_direction)*255
        if intensity > 0
            level = intensity.to_i.to_s(16).rjust(2, "0") * 3
            a, b, c = vertex_ids.map{ |id| center - (object.vertices[id] * center) }
            bitmap.setpixels(triangle(a, b, c), level)
        end
    end
    bitmap.writetofile("renderer - " + filename + " - " + Time.now.to_s[0..-7] + ".bmp")
end

render_model("wt_teapot.obj")
render_model("african_head.obj")

