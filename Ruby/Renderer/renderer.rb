require_relative 'bitmap'
require_relative 'drawing'
require_relative 'matrix_math'
require_relative 'point'
require_relative 'utilities'
require_relative 'wavefront'

ScreenWidth = 384
ScreenHeight = 384

Start_Time = Time.now

def clamp(value, min, max)
    return min if value < min
    return max if value > max
    return value
end

def render_model(object, texture, normalmap, specmap)
    width = ScreenWidth; height = ScreenHeight
    screen_center = Point((width/2), (height/2), 255)
    screen_size = Point(width - 1, height - 1)

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
    total_pixels = 0

    object.each_face do |face|
        normal = compute_face_normal(face).apply_matrix!(normal_matrix).scalar_product(camera_direction)
        next if normal > 0 #bail if the polygon isn't facing us
        drawn_faces += 1

        face = face_to_screen(face, view_matrix, screen_center)

        verts = face.map(&:v)
        uvs = face.map(&:uv)
        normals = face.map(&:normal)
        tangents = face.map(&:tangent)
        bitangents = face.map(&:bitangent)

        barycentric_points = triangle(verts)
        total_pixels += barycentric_points.length

        for barycentric in barycentric_points do
            #get the screen coordinate
            screen_coord = barycentric.to_cartesian(verts).round!
            if z_buffer.should_draw?(screen_coord)
                #get the color from the texture
                texture_coord = barycentric.to_cartesian(uvs).to_texture!(texture_size).round!
                color = texture.get_pixel(texture_coord)
                #compute diffuse light intensity from tangent normal
                tbn = [ barycentric.to_cartesian(tangents),
                        barycentric.to_cartesian(bitangents),
                        barycentric.to_cartesian(normals) ]
                tangent_normal = normalmap.get_normal(texture_coord).dup
                normal = tangent_normal.apply_tangent_matrix!(tbn).apply_matrix!(normal_matrix).normalize!
                diffuse_intensity = clamp((normal.scalar_product(light_direction) * -1), 0, 1)
                #compute specular highlight intensity
                specular_power = specmap.get_specular(texture_coord)
                reflection = normal.compute_reflection(light_direction).scalar_product(camera_direction)*-1
                reflection_intensity = clamp(reflection, 0, 1)**specular_power
                #combine lighting information for shading
                shaded_color = color.multiply(0.05 + 0.6*reflection_intensity + 0.75*diffuse_intensity)
                #finally write our pixel
                bitmap.set_pixel(screen_coord, shaded_color)
            end
        end
    end
    rescue Exception => e
        write_bitmap(bitmap)
        raise e
    end
    write_bitmap(bitmap)
    overdraw = (100.0 * z_buffer.drawn_pixels) / (total_pixels)
    log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
    log( "#{total_pixels} points generated" )
    log( "  #{z_buffer.occluded_pixels} pixels occluded" )
    log( "  #{z_buffer.oob_pixels} pixels offscreen" )
    log( "  #{z_buffer.drawn_pixels} pixels drawn" )
    log( "#{overdraw.round(3)}% efficiency" )
    log( (Time.now - start_time).round(3).to_s + " seconds taken")
end

object = Wavefront.from_file("african_head.obj")
texture = load_texture("african_head_diffuse.png")
normalmap = TangentSpaceNormalMap.new("african_head_nm_tangent.png")
specmap = SpecularMap.new("african_head_spec.png")
log("Rendering model")
render_model(object, texture, normalmap, specmap)

