require_relative 'bitmap'
require_relative 'point'
require_relative 'drawing'
require_relative 'wavefront'
require_relative 'matrix_math'

ScreenWidth = 384
ScreenHeight = 384
White = Pixel.new(255, 255, 255)

Start_Time = Time.now

def log(string)
    elapsed = (Time.now - Start_Time).round(3)
    puts "#{elapsed}: #{string}"
end

def write_bitmap(bitmap)
        bitmap.writetofile("output/renderer - " + Time.now.to_s[0..-7] + ".bmp")
end

def clamp(value, min, max)
    return min if value < min
    return max if value > max
    return value
end

def render_model(filename, texture_filename, normalmap_filename, specmap_filename)
    log("Rendering model: #{filename}")
    object = Wavefront.from_file(filename)
    width = ScreenWidth; height = ScreenHeight
    screen_center = Point((width/2), (height/2), 32768)
    screen_size = Point(width - 1, height - 1)

    texture = load_texture(texture_filename)
    normalmap = load_texture(normalmap_filename)
    specmap = load_texture(specmap_filename)

    start_time = Time.now

    texture_size = Point(texture.width - 1, texture.height - 1)
    bitmap = Bitmap.new(width, height)
    z_buffer = Z_Buffer.new(width, height)

    #view_matrix = compute_view_matrix(0, 0, 0, -1)
    view_matrix = compute_view_matrix(20, -20, -5, 5)
    normal_matrix = view_matrix.inverse.transpose.to_a #to_a for performance
    view_matrix = view_matrix.to_a                     #to_a for performance

    camera_direction = Point(0, 0, -1)
    light_direction = Point(0, 0, -1)
    ambient_light = Pixel.from_gray(5)

    begin
    drawn_faces = 0
    drawn_pixels = 0
    log("#{drawn_faces} faces drawn")
    object.each_face do |face|
        normal = compute_face_normal(face).apply_matrix!(normal_matrix).scalar_product(camera_direction)
        next if normal > 0 #bail if the polygon isn't facing us

        drawn_faces += 1
        log("#{drawn_faces} faces drawn") if drawn_faces % 100 == 0
        level_of_detail = compute_triangle_resolution(face, screen_center)

        barycentric_points = triangle(level_of_detail)

        verts = face.map(&:v)
        uvs = face.map(&:uv)
        normals = face.map(&:normal)
        tangents = face.map(&:tangent)
        bitangents = face.map(&:bitangent)

        for barycentric in barycentric_points do
            #get the screen coordinate
            vertex = convert_barycentric(verts, barycentric)
            screen_coord = vertex.apply_matrix!(view_matrix).to_screen!(screen_center)
            if z_buffer.should_draw?(screen_coord)
                #get the color from the texture
                texture_coord = convert_barycentric(uvs, barycentric).to_texture!(texture_size)
                color = texture.get_pixel(texture_coord)
                #compute diffuse light intensity from tangent normal
                tbn = [ convert_barycentric(tangents, barycentric),
                        convert_barycentric(bitangents, barycentric),
                        convert_barycentric(normals, barycentric) ]
                tangent_normal = normalmap.get_pixel(texture_coord).to_normal
                normal = tangent_normal.apply_tangent_matrix!(tbn).apply_matrix!(normal_matrix).normalize!
                diffuse_intensity = clamp((normal.scalar_product(light_direction) * -1), 0, 1)
                #compute specular highlight intensity
                specular_power = clamp((1-specmap.get_pixel(texture_coord).r/255)*100, 1, 24)
                reflection = normal.compute_reflection(light_direction).scalar_product(camera_direction)*-1
                reflection_intensity = clamp(reflection, 0, 1)**specular_power
                #combine lighting information for shading
                shaded_color = color.multiply(0.05 + 0.6*reflection_intensity + 0.75*diffuse_intensity)
                #finally write our pixel
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
    overdraw = (100.0 * drawn_pixels) / (width * height)
    log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
    log( "#{drawn_pixels} pixels drawn" )
    log( "#{overdraw.round(3)}% pixel overdraw" )
    log( (Time.now - start_time).round(3).to_s + " seconds taken")
end

render_model("african_head.obj",
            "african_head_diffuse.png",
            "african_head_nm_tangent.png",
            "african_head_spec.png")



