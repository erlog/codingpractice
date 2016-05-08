require 'oily_png'

def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def load_object(object_name)
    object = Wavefront.from_file("objects/#{object_name}/object.obj")
    texture = load_texture("objects/#{object_name}/diffuse.png")
    normalmap = NormalMap.new(load_texture("objects/#{object_name}/nm_tangent.png"))
    specmap = SpecularMap.new(load_texture("objects/#{object_name}/spec.png"))
    output = [object.faces, texture, normalmap, specmap]
    return output
end

def load_texture(filename)
    log("Loading texture: #{filename}")
    png = ChunkyPNG::Image.from_file(filename)
    width, height = png.width, png.height
    bitmap = Bitmap.new(png.width, png.height, 0)
    coord = Point.new(0, png.height - 1, 0)

    for int32 in png.pixels
        bitmap.set_pixel(coord, int32)

        coord.x += 1
        if coord.x == width
            coord.x = 0; coord.y -= 1
        end
    end
    return bitmap
end
