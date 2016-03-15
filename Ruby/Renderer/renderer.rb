require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'
require 'chunky_png'

Width = 512
Height = 512

def gray(value)
    value = value.to_i & 255
    return value.to_s(16).rjust(2, "0")*3
end

def render_model(filename, width = Width, height = Height)
    center = Point((width/2) - 1, (height/2) - 1, width*height*-1)
    texture = ChunkyPNG::Image.from_file('african_head_diffuse.png').flip_horizontally!
    object = Wavefront.new(filename)
    z_buffer = Z_Buffer.new(width, height)
    bitmap = Bitmap.new(width, height)
    light_direction = Point(0, 0, -1)

    object.faces.each do |face|
        light_level = (face.compute_normal.scalar_product(light_direction)*255).to_i
        if light_level > 0
            a, b, c = face.to_screen(center)
            triangle(a, b, c).each do |coord|
                relative = (a - coord) / Point(width, height, 1)
                texture_coord = (face.vt[0] + relative) * Point(1023, 1023)
                texture_coord = texture_coord.to_i
                color_int32 = texture.get_pixel(texture_coord.x, texture_coord.y)
                color = Pixel.from_int32(color_int32)
                z_depth = z_buffer.getpixel(coord)
                if !z_depth or (coord.z >= z_depth)
                    bitmap.setpixel(coord, Pixel.new(light_level, light_level, light_level))
                    z_buffer.setpixel(coord)
                end
            end
        end
    end
    bitmap.writetofile("renderer - " + filename + " - " + Time.now.to_s[0..-7] + ".bmp")
end

render_model("african_head.obj")


