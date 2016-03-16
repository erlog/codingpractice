require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'

ScreenWidth = 512
ScreenHeight = 512
TextureWidth = 1024
TextureHeight = 1024
White = Pixel.new(255, 255, 255)
Grey = Pixel.new(128, 128, 128)

Start_Time = Time.now

def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def write_bitmap(bitmap)
        bitmap.writetofile("output/renderer - " + Time.now.to_s[0..-7] + ".bmp")
end

def render_model(filename, texture_filename = nil, bumpmap_filename = nil)
    log("Rendering model: #{filename}")
    width = ScreenWidth; height = ScreenHeight
    screen_center = Point((width/2), (height/2), width+height)
    screen_size = Point(width - 1, height - 1)

    texture = load_texture(texture_filename) if texture_filename
    log("Loaded bump map")
    normalmap = load_texture(bumpmap_filename) if bumpmap_filename
    log("Loaded texture")
    start_time = Time.now

    texture_size = Point(texture.width - 1, texture.height - 1)
    object = Wavefront.from_file(filename)
    log("Loaded model")
    bitmap = Bitmap.new(width, height)
    z_buffer = Z_Buffer.new(width, height)

    #object = object.rotate(20, 20, 5)
    light_direction = Point(0, 0, -1)

    begin
    drawn_faces = 0
    drawn_pixels = 0
    object.each_face do |face|
        face = face.project(5)
        estimated_normal = face.compute_normal.scalar_product(light_direction)
        next if estimated_normal < 0 #bail if the polygon isn't facing us and isn't lit

        drawn_faces += 1
        log("#{drawn_faces} faces drawn") if drawn_faces % 100 == 0
        level_of_detail = compute_triangle_resolution(face.to_screen(screen_center))

        geometric_points = triangle(face.v, level_of_detail)
        #normal_points = triangle(face.vn, level_of_detail)
        texture_points = triangle(face.vt, level_of_detail)

        (0..geometric_points.length - 1).each do |i|
            screen_coord = geometric_points[i].to_screen(screen_center)
            next if !bounds_check(screen_coord, screen_size)
            z_depth = z_buffer.get_pixel(screen_coord)
            if !z_depth or (screen_coord.z < z_depth)
                #grab color information from texture and apply normal information
                texture_coord = (texture_points[i] * texture_size).to_i
                normal = normalmap.get_pixel(texture_coord).to_normal
                intensity = normal.scalar_product(light_direction) * -1
                next if intensity < 0
                color = texture.get_pixel(texture_coord).multiply(intensity)
                #finally draw a pixel
                bitmap.set_pixel(screen_coord, color)
                #make a record in the depth buffer
                z_buffer.set_pixel(screen_coord)
                drawn_pixels += 1
            end
        end
    end
    rescue Exception => e
        write_bitmap(bitmap)
        raise e
    end
    write_bitmap(bitmap)
    overdraw = (100.0 * drawn_pixels) / (width * height)
    log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
    log( "#{overdraw.round(3)}% pixel overdraw" )
    log( (Time.now - start_time).round(3).to_s + " seconds taken")
end

render_model("african_head.obj",
            "african_head_diffuse.png",
            "african_head_nm.png")



