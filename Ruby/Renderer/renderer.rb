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

def render_model(faces, view_matrix, normal_matrix,
                    camera_direction, light_direction,
                    bitmap, z_buffer, texture, normalmap, specmap)

    screen_center = Point.new((bitmap.width/2), (bitmap.height/2), 255)
    texture_size = Point.new(texture.width - 1, texture.height - 1, 0)

    faces.each do |face|
        normal = compute_face_normal(face).apply_matrix!(normal_matrix).scalar_product(camera_direction)
        next if normal > 0 #bail if the polygon isn't facing us

        face = face_to_screen(face, view_matrix, screen_center)
        verts = face.map(&:v)
        uvs = face.map(&:uv)
        normals = face.map(&:normal)
        tangents = face.map(&:tangent)
        bitangents = face.map(&:bitangent)

        triangle(verts){ |barycentric|
            #get the screen coordinate
            screen_coord = barycentric.to_cartesian_screen(verts)
            if z_buffer.should_draw?(screen_coord)
                barycentric.to_barycentric_clip!(verts) #for perspective-aware uv interpolation
                #get the color from the texture
                texture_coord = barycentric.to_texture(uvs, texture_size)
                color = texture.get_pixel(texture_coord)
                #compute diffuse light intensity from tangent normal
                tangent_normal = normalmap.get_normal(texture_coord)
                normal = barycentric.to_normal(normal_matrix, tangent_normal, tangents, bitangents, normals)
                diffuse_intensity = normal.scalar_product(light_direction) * -1
                #compute specular highlight intensity
                specular_power = specmap.get_specular(texture_coord)
                reflection_intensity = normal.compute_reflection(light_direction,
                                            camera_direction, specular_power)
                #combine lighting information for shading
                factor = 0.05 + 0.6*reflection_intensity + 0.75*diffuse_intensity
                shaded_color = color_multiply(color, factor)
                #finally write our pixel
                bitmap.set_pixel(screen_coord, shaded_color)
            end
        }
    end
end

view_matrix = compute_view_matrix(20, -20, -5, 5)
normal_matrix = C_Matrix.new(view_matrix.inverse.transpose.to_a.flatten)
view_matrix = C_Matrix.new(view_matrix.to_a.flatten)

camera_direction = Point.new(0, 0, -1)
light_direction = Point.new(0, 0, -1)

bitmap = Bitmap.new(ScreenWidth, ScreenHeight, [0,0,0])
z_buffer = Z_Buffer.new(bitmap.width, bitmap.height)
object_name = "african_head"
object = Wavefront.from_file("objects/#{object_name}/object.obj")
texture = load_texture("objects/#{object_name}/diffuse.png")
normalmap = NormalMap.new(load_texture("objects/#{object_name}/nm_tangent.png"))
specmap = SpecularMap.new(load_texture("objects/#{object_name}/spec.png"))

log("Rendering model")
start_time = Time.now
if Profile
    RubyProf.start
    render_model(object.faces, view_matrix, normal_matrix,
                    camera_direction, light_direction,
                    bitmap, z_buffer, texture, normalmap, specmap)
    result = RubyProf.stop

    # print a flat profile to text
     printer = RubyProf::FlatPrinter.new(result)
     printer.print(STDOUT)
else
    render_model(object.faces, view_matrix, normal_matrix,
                    camera_direction, light_direction,
                    bitmap, z_buffer, texture, normalmap, specmap)
end
end_time = Time.now

total_pixels = z_buffer.occluded_pixels + z_buffer.oob_pixels + z_buffer.drawn_pixels
overdraw = (100.0 * z_buffer.drawn_pixels) / (total_pixels)
#log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
log( "#{total_pixels} points generated" )
log( "  #{z_buffer.occluded_pixels} pixels occluded" )
log( "  #{z_buffer.oob_pixels} pixels offscreen" )
log( "  #{z_buffer.drawn_pixels} pixels drawn" )
log( "#{overdraw.round(3)}% efficiency" )
log( (end_time - start_time).round(3).to_s + " seconds taken")
log( (1.0/(end_time - start_time)).round(3).to_s + " FPS")

write_bitmap(bitmap)
