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
    drawn_faces = render_model(object.faces, view_matrix, normal_matrix,
                    camera_direction, light_direction,
                    bitmap, z_buffer, texture, normalmap, specmap)
    result = RubyProf.stop

    # print a flat profile to text
     printer = RubyProf::FlatPrinter.new(result)
     printer.print(STDOUT)
else
    drawn_faces = render_model(object.faces, view_matrix, normal_matrix,
                    camera_direction, light_direction,
                    bitmap, z_buffer, texture, normalmap, specmap)
end
end_time = Time.now

total_pixels = z_buffer.occluded_pixels + z_buffer.oob_pixels + z_buffer.drawn_pixels
overdraw = (100.0 * z_buffer.drawn_pixels) / (total_pixels)
log( "#{drawn_faces}/#{object.faces.length} faces drawn" )
log( "#{total_pixels} points generated" )
log( "  #{z_buffer.occluded_pixels} pixels occluded" )
log( "  #{z_buffer.oob_pixels} pixels offscreen" )
log( "  #{z_buffer.drawn_pixels} pixels drawn" )
log( "#{overdraw.round(3)}% efficiency" )
log( (end_time - start_time).round(3).to_s + " seconds taken")
log( (1.0/(end_time - start_time)).round(3).to_s + " FPS")

write_bitmap(bitmap)
