require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'
require 'chunky_png'

Width = 512
Height = 512

def convertpngcolor(integer)
    return "FF0000" if !integer
    return integer.to_s(16).rjust(8, "0")[0..5]
end

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
        light_level = face.compute_normal.scalar_product(light_direction)*255
        if light_level > 0
            a, b, c = face.to_screen(center)
            triangle(a, b, c).each do |pixel|
                relative = (a - pixel) / Point(width, height, 1)
                texture_coord = (face.vt[0] + relative) * Point(1023, 1023)
                texture_coord = texture_coord.to_i
                color_int = texture.get_pixel(texture_coord.x, texture_coord.y)
                color = convertpngcolor(color_int)
                z_depth = z_buffer.getpixel(pixel)
                if !z_depth or (pixel.z >= z_depth)
                    bitmap.setpixel(pixel, color)
                    z_buffer.setpixel(pixel)
                end
            end
        end
    end
    bitmap.writetofile("renderer - " + filename + " - " + Time.now.to_s[0..-7] + ".bmp")
end

render_model("african_head.obj")


