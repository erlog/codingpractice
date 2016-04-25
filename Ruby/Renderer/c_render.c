#include "ruby.h"
#include "stdbool.h"
#include "float.h"

#include "c_optimization_main.h"
#include "c_point.h"
#include "c_bitmap.h"

VALUE render_model(VALUE self, VALUE rb_object,
                VALUE rb_view_matrix, VALUE rb_normal_matrix,
                VALUE rb_camera_direction, VALUE rb_light_direction,
                VALUE rb_bitmap, VALUE rb_zbuffer,
                VALUE rb_texture, VALUE rb_normalmap, VALUE rb_specmap) {

    Bitmap* bitmap; Data_Get_Struct(rb_bitmap, Bitmap, bitmap);

}

/**
def render_model_backup(bitmap, object, texture, normalmap, specmap)
    screen_center = Point.new((bitmap.width/2), (bitmap.height/2), 255)


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
                diffuse_intensity = normal.scalar_product(light_direction)
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
**/
