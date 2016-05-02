require 'oily_png'

def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def write_bitmap(bitmap)
        bitmap.writetofile("output/renderer - " + Time.now.to_s[0..-7] + ".bmp")
end

def load_object(object_name)
    object = Wavefront.from_file("objects/#{object_name}/object.obj")
    texture = load_texture("objects/#{object_name}/diffuse.png")
    normalmap = NormalMap.new(load_texture("objects/#{object_name}/nm_tangent.png"))
    specmap = SpecularMap.new(load_texture("objects/#{object_name}/spec.png"))
    return [object, texture, normalmap, specmap]
end

def load_texture(filename)
    log("Loading texture: #{filename}")
    png = ChunkyPNG::Image.from_file(filename)
    width, height = png.width, png.height
    bitmap = Bitmap.new(png.width, png.height, [0,0,0])
    coord = Point.new(0, png.height - 1, 0)

    for int32 in png.pixels
        int24 = int32 >> 8;
        bitmap.set_pixel(coord, int24)

        coord.x += 1
        if coord.x == width
            coord.x = 0; coord.y -= 1
        end
    end
    return bitmap
end
