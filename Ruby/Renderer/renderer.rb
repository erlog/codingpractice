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

def render_model(filename, width = ScreenWidth, height = ScreenHeight)
    screen_center = Point((width/2) - 1, (height/2) - 1, (width+height)*-1)
    texture = ChunkyPNG::Image.from_file('african_head_diffuse.png').flip_horizontally!
    texture_size = Point(TextureWidth - 1, TextureHeight - 1, 0)
    object = Wavefront.new(filename)
    bitmap = Bitmap.new(width, height)
    z_buffer = Z_Buffer.new(width, height)

    light_direction = Point(0, 0, -1)
    object.faces.each do |face|
        light_level = face.compute_normal.scalar_product(light_direction)
        if light_level > 0
            level_of_detail = compute_triangle_resolution(face.to_screen(screen_center))

            geometric_points = triangle(face.v, level_of_detail)
            texture_points = triangle(face.vt, level_of_detail)
            normal_points = triangle(face.vn, level_of_detail)

            (0..geometric_points.length - 1).each do |i|
                screen_coord = geometric_points[i].to_screen(screen_center)
                z_depth = z_buffer.get_pixel(screen_coord)
                if !z_depth or (screen_coord.z >= z_depth)
                    #make a record in the z_buffer
                    z_buffer.set_pixel(screen_coord)
                    #grab info from the normal map
                    normal = normal_points[i].scalar_product(light_direction).abs
                    #grab color information from texture
                    texture_coord = (texture_points[i] * texture_size).to_i
                    color_int32 = texture.get_pixel(texture_coord.x, texture_coord.y)
                    #apply normal info to the pixel from the texture
                    color = Pixel.from_int32(color_int32).multiply(normal)
                    #finally draw a pixel
                    bitmap.set_pixel(screen_coord, color)
                end
            end
        end
    end
    bitmap.writetofile("renderer - " + Time.now.to_s[0..-7] + ".bmp")
end

render_model("african_head.obj")


