require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'
require_relative 'matrix_math'

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

def clamp(value, min, max)
    return [[max, value].min, max].min
end

def render_model(filename, texture_filename, normalmap_filename, specmap_filename)
    log("Rendering model: #{filename}")
    object = Wavefront.from_file(filename)
    width = ScreenWidth; height = ScreenHeight
    screen_center = Point((width/2), (height/2), 2048)
    screen_size = Point(width - 1, height - 1)

    texture = load_texture(texture_filename)
    normalmap = load_texture(normalmap_filename)
    specmap = load_texture(specmap_filename)

    start_time = Time.now

    texture_size = Point(texture.width - 1, texture.height - 1)
    bitmap = Bitmap.new(width, height)
    z_buffer = Z_Buffer.new(width, height)

    #view_matrix = compute_view_matrix(0, 0, 0, 5)
    view_matrix = compute_view_matrix(20, -20, -5, 5)
    normal_matrix = view_matrix.inverse.transpose
    camera_direction = Point(0, 0, -1)
    light_direction = Point(0, -1, -1).normalize
    ambient_light = Pixel.from_gray(5)

    begin
    drawn_faces = 0
    drawn_pixels = 0
    object.each_face do |face|
        normal = compute_face_normal(face).apply_matrix(normal_matrix).scalar_product(camera_direction)
        next if normal > 0 #bail if the polygon isn't facing us

        drawn_faces += 1
        log("#{drawn_faces} faces drawn") if drawn_faces % 100 == 0
        bitmap.writetofile("#{drawn_faces}.bmp") if drawn_faces % 300 == 0
        level_of_detail = compute_triangle_resolution(face, screen_center)

        geometric_points = triangle(face.map(&:v), level_of_detail)
        texture_points = triangle(face.map(&:uv), level_of_detail)
        normal_points = triangle(face.map(&:normal), level_of_detail)
        tangent_points = triangle(face.map(&:tangent), level_of_detail)
        bitangent_points = triangle(face.map(&:bitangent), level_of_detail)

        (0..geometric_points.length - 1).each do |i|
            screen_coord = geometric_points[i].apply_matrix(view_matrix).to_screen(screen_center).xy_to_i
            next if !bounds_check(screen_coord, screen_size) #bail if we're out of bounds
            if z_buffer.should_draw?(screen_coord)
                texture_coord = (texture_points[i] * texture_size).to_i
                tangent_normal = normalmap.get_pixel(texture_coord).to_normal
                tbn_matrix = get_tbn_matrix(tangent_points[i], bitangent_points[i], normal_points[i])
                normal = tangent_normal.apply_tangent_matrix(tbn_matrix).apply_matrix(normal_matrix).normalize
                intensity = clamp((normal.scalar_product(light_direction) * -1), 0, 1)
                color = texture.get_pixel(texture_coord)
                shaded_color = color.multiply(intensity) + ambient_light
                bitmap.set_pixel(screen_coord, shaded_color)
                drawn_pixels += 1
            end
        end
    end
    rescue Exception => e
        write_bitmap(bitmap)
        raise e
    end
    write_bitmap(bitmap)
    bitmap.writetofile("3000.bmp")
    overdraw = (100.0 * drawn_pixels) / (width * height)
    log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
    log( "#{overdraw.round(3)}% pixel overdraw" )
    log( (Time.now - start_time).round(3).to_s + " seconds taken")
end

render_model("african_head.obj",
            "african_head_diffuse.png",
            "african_head_nm_tangent.png",
            "african_head_spec.png")



