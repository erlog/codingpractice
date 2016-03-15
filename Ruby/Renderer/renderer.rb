require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'
require 'chunky_png'

ScreenWidth = 512
ScreenHeight = 512
TextureWidth = 1024
TextureHeight = 1024
White = Pixel.new(255, 255, 255)

Start_Time = Time.now

def load_texture(filename)
    png = ChunkyPNG::Image.from_file('african_head_diffuse.png')
    bitmap = Bitmap.new(png.width, png.height)
    (0..png.height - 1).each do |y|
        (0..png.width - 1).each do |x|
            coord = Point(x, png.height - 1 - y) #need to flip texture vertically
            pixel = Pixel.from_int32(png.get_pixel(x, y))
            bitmap.set_pixel(coord, pixel)
        end
    end
    return bitmap
end

def bounds_check(point, maximum_point)
    if (point.x < 0)
        return false
    elsif (point.x >= maximum_point.x)
        return false
    elsif (point.y < 0)
        return false
    elsif (point.y >= maximum_point.y)
        return false
    end

    return true
end

def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def render_model(filename, texture_filename, width = ScreenWidth, height = ScreenHeight)
    log("Rendering model: #{filename}")

    screen_center = Point((width/2) - 1, (height/2) - 1, (width+height)*-1)
    screen_size = Point(width - 1, height - 1)
    texture = load_texture(texture_filename)

    log("Loaded texture")
    start_time = Time.now

    texture_size = Point(texture.width - 1, texture.height - 1, 0)
    object = Wavefront.new(filename)
    bitmap = Bitmap.new(width, height)
    z_buffer = Z_Buffer.new(width, height)

    light_direction = Point(0, 0, -1)
    object.project(5)

    begin
    drawn_faces = 0
    object.faces.each do |face|
        light_level = face.compute_normal.scalar_product(light_direction)
        if light_level > 0
            drawn_faces += 1
            level_of_detail = compute_triangle_resolution(face.to_screen(screen_center))

            geometric_points = triangle(face.v, level_of_detail)
            texture_points = triangle(face.vt, level_of_detail)
            normal_points = triangle(face.vn, level_of_detail)

            (0..geometric_points.length - 1).each do |i|
                screen_coord = geometric_points[i].to_screen(screen_center)
                next if !bounds_check(screen_coord, screen_size)
                z_depth = z_buffer.get_pixel(screen_coord)
                if !z_depth or (screen_coord.z >= z_depth)
                    #make a record in the z_buffer
                    z_buffer.set_pixel(screen_coord)
                    #grab info from the normal map
                    normal = normal_points[i].scalar_product(light_direction).abs
                    #grab color information from texture and apply normal information
                    texture_coord = (texture_points[i] * texture_size).to_i
                    color = texture.get_pixel(texture_coord).multiply(normal)
                    #finally draw a pixel
                    bitmap.set_pixel(screen_coord, color)
                end
            end
        end
    end
    rescue Exception => e
        bitmap.writetofile("renderer - " + Time.now.to_s[0..-7] + ".bmp")
        raise e
    end
    bitmap.writetofile("renderer - " + Time.now.to_s[0..-7] + ".bmp")

    log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
    log( (Time.now - start_time).round(3).to_s + " seconds taken")
end

render_model("african_head.obj", "african_head_diffuse.png")


