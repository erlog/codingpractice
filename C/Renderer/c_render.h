#ifndef C_RENDER_H
#define C_RENDER_H

VALUE render_model(VALUE self, VALUE rb_faces,
                VALUE rb_view_matrix, VALUE rb_normal_matrix,
                VALUE rb_camera_direction, VALUE rb_light_direction,
                VALUE rb_bitmap, VALUE rb_zbuffer,
                VALUE rb_texture, VALUE rb_normalmap, VALUE rb_specmap);
#endif
