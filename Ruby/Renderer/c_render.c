#include "ruby.h"
#include "stdbool.h"
#include "float.h"

#include "c_optimization_main.h"
#include "c_point.h"
#include "c_bitmap.h"

bool should_draw_face(Point* a_v, Point* b_v, Point* c_v,
                            float* normal_matrix, Point* camera_direction) {
    Point left = { b_v->x - a_v->x, b_v->y - a_v->y, b_v->z - a_v->z };
    Point right = { c_v->x - a_v->x, c_v->y - a_v->y, c_v->z - a_v->z };

    Point normal = cross_product(&left, &right); normalize(&normal);
    apply_matrix(&normal, normal_matrix);
    float result = scalar_product(&normal, camera_direction);

    if(result < 0) { return true; } //this means the polygon isn't facing us
    return false;
}

void sort_vertices(Vertex** a, Vertex** b, Vertex** c) {
    Vertex* extra;
    if((*c)->screen_v->y > (*b)->screen_v->y) {
        extra = *b; *b = *c; *c = extra;
    }
    if(((*c)->screen_v->y == (*b)->screen_v->y) &&
                                    ((*c)->screen_v->x < (*b)->screen_v->x)) {
        extra = *b; *b = *c; *c = extra;
    }
    if((*b)->screen_v->y > (*a)->screen_v->y) {
        extra = *a; *a = *b; *b = extra;
    }
    if(((*b)->screen_v->y == (*a)->screen_v->y) &&
                                    ((*b)->screen_v->x < (*a)->screen_v->x)) {
        extra = *a; *a = *b; *b = extra;
    }
    if((*c)->screen_v->y > (*b)->screen_v->y) {
        extra = *b; *b = *c; *c = extra;
    }
    if(((*c)->screen_v->y == (*b)->screen_v->y) &&
                                    ((*c)->screen_v->x < (*b)->screen_v->x)) {
        extra = *b; *b = *c; *c = extra;
    }
    return;
}

inline void face_to_screen(Vertex* a, Vertex* b, Vertex* c,
                                float* view_matrix, Point* screen_center) {
    Point_clone(a->v, a->screen_v);
    Point_clone(b->v, b->screen_v);
    Point_clone(c->v, c->screen_v);
    apply_matrix(a->screen_v, view_matrix);
    apply_matrix(b->screen_v, view_matrix);
    apply_matrix(c->screen_v, view_matrix);
    point_to_screen(a->screen_v, screen_center);
    point_to_screen(b->screen_v, screen_center);
    point_to_screen(c->screen_v, screen_center);
    return;
}

VALUE rb_render_model(VALUE self, VALUE rb_faces,
                VALUE rb_view_matrix, VALUE rb_normal_matrix,
                VALUE rb_camera_direction, VALUE rb_light_direction,
                VALUE rb_bitmap, VALUE rb_zbuffer,
                VALUE rb_texture, VALUE rb_normalmap, VALUE rb_specmap) {

    Bitmap* bitmap; Data_Get_Struct(rb_bitmap, Bitmap, bitmap);
    Bitmap* texture; Data_Get_Struct(rb_texture, Bitmap, texture);
    ZBuffer* zbuffer; Data_Get_Struct(rb_zbuffer, ZBuffer, zbuffer);
    NormalMap* normalmap; Data_Get_Struct(rb_normalmap, NormalMap, normalmap);
    SpecularMap* specmap; Data_Get_Struct(rb_specmap, SpecularMap, specmap);

    Matrix* matrix_struct;
    Data_Get_Struct(rb_view_matrix, Matrix, matrix_struct);
    float* view_matrix = matrix_struct->m;
    Data_Get_Struct(rb_normal_matrix, Matrix, matrix_struct);
    float* normal_matrix = matrix_struct->m;

    Point* camera_direction; Data_Get_Struct(rb_camera_direction, Point, camera_direction);
    Point* light_direction; Data_Get_Struct(rb_light_direction, Point, light_direction);

    Point screen_center =
        {(float)(bitmap->width/2),(float)(bitmap->height/2), 255.0};
    Point texture_size =
        {(float)(texture->width-1),(float)(texture->height-1), 0.0};


    int number_of_faces = RARRAY_LEN(rb_faces);
    int drawn_faces = 0;
    int number_of_points;
    int face_i; int point_i;
    int32_t color = color_to_bgr(255, 255, 255);
    VALUE face;
    Vertex* a; Vertex* b; Vertex* c;
    Point* bary;
    Point screen_coord;
    Point texture_coord;
    Point* tangent_normal;
    Point normal;
    Point* point_list;
    float diffuse_intensity;
    float specular_power;
    float reflectivity;
    float factor;

    for(face_i = 0; face_i < number_of_faces; face_i++) {
        face = rb_ary_entry(rb_faces, face_i);
        Data_Get_Struct(rb_ary_entry(face, 0), Vertex, a);
        Data_Get_Struct(rb_ary_entry(face, 1), Vertex, b);
        Data_Get_Struct(rb_ary_entry(face, 2), Vertex, c);
        if(should_draw_face(a->v, b->v, c->v, normal_matrix,
                                                        camera_direction)) {
            drawn_faces++;
            //project face to screen
            face_to_screen(a, b, c, view_matrix, &screen_center);
            sort_vertices(&a, &b, &c);

            number_of_points = triangle(&point_list, a->screen_v,
                                                    b->screen_v, c->screen_v);
            for(point_i = 0; point_i < number_of_points; point_i++) {
                bary = &point_list[point_i];
                barycentric_to_cartesian(bary, &screen_coord, a->screen_v,
                                                    b->screen_v, c->screen_v);
                screen_coord.x = roundf(screen_coord.x);
                screen_coord.y = roundf(screen_coord.y);
                //convert to clip coordinates
                to_barycentric_clip(bary, a->screen_v, b->screen_v, c->screen_v);

                if(zbuffer_should_draw(zbuffer, &screen_coord)) {
                    point_to_texture(bary, &texture_coord, &texture_size,
                                                        a->uv, b->uv, c->uv);
                    //compute diffuse from tangent normal
                    tangent_normal = get_normal(normalmap, &texture_coord);
                    convert_tangent_normal(tangent_normal, bary,
                                            &normal, normal_matrix, a, b, c);
                    diffuse_intensity = scalar_product(&normal,
                                                        light_direction) * -1;
                    //compute specularity
                    specular_power = get_specular(specmap, &texture_coord);
                    reflectivity = compute_reflection(&normal, light_direction,
                                            camera_direction, specular_power);
                    //light our pixel with the information
                    color = bitmap_get_pixel(texture, &texture_coord);
                    factor = 0.05 + 0.6*reflectivity + 0.75*diffuse_intensity;
                    color = color_multiply(color, factor);
                    bitmap_set_pixel(bitmap, &screen_coord, color);
                }
            }
            free(point_list);
        }
    }

    return INT2NUM(drawn_faces);
}
