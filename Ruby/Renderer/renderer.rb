require_relative 'bitmap'
require_relative 'matrix_math'
require_relative 'point'
require_relative 'utilities'
require_relative 'wavefront'
require_relative 'c_optimization'; include C_Optimization
require 'ruby-prof'

Profile = (ARGV[0] == "-profile")
ScreenWidth = 384
ScreenHeight = 384

Start_Time = Time.now

def render_model(bitmap, object, texture, normalmap, specmap)
    screen_center = Point.new((bitmap.width/2), (bitmap.height/2), 255)
    screen_size = Point.new(bitmap.width - 1, bitmap.height - 1, 0)

    start_time = Time.now

    texture_size = Point.new(texture.width - 1, texture.height - 1, 0)
    z_buffer = Z_Buffer.new(bitmap.width, bitmap.height)

    view_matrix = compute_view_matrix(20, -20, -5, 5)
    normal_matrix = C_Matrix.new(view_matrix.inverse.transpose.to_a.flatten)
    view_matrix = C_Matrix.new(view_matrix.to_a.flatten)

    camera_direction = Point.new(0, 0, -1)
    light_direction = Point.new(0, 0, -1)
    ambient_light = Pixel.new(5,5,5)

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

        triangle(verts){ |barycentric|
            total_pixels += 1
            #get the screen coordinate
            screen_coord = barycentric.to_cartesian_screen(verts)
            if z_buffer.should_draw?(screen_coord)
                #get the color from the texture
                texture_coord = barycentric.to_cartesian(uvs).to_texture!(texture_size)
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
                reflection = normal.compute_reflection!(light_direction).scalar_product(camera_direction)*-1
                reflection_intensity = clamp(reflection, 0, 1)**specular_power
                #combine lighting information for shading
                shaded_color = color.multiply(0.05 + 0.6*reflection_intensity + 0.75*diffuse_intensity)
                #finally write our pixel
                bitmap.set_pixel(screen_coord, shaded_color)
            end
        }
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

bitmap = Bitmap.new(ScreenWidth, ScreenHeight)
object = Wavefront.from_file("african_head.obj")
texture = load_texture("african_head_diffuse.png")
normalmap = TangentSpaceNormalMap.new("african_head_nm_tangent.png")
specmap = SpecularMap.new("african_head_spec.png")
log("Rendering model")
if Profile
    RubyProf.start
    render_model(bitmap, object, texture, normalmap, specmap)
    result = RubyProf.stop

    # print a flat profile to text
     printer = RubyProf::FlatPrinter.new(result)
     printer.print(STDOUT)
else
    render_model(bitmap, object, texture, normalmap, specmap)
end

