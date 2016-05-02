#ifndef C_POINT_H
#define C_POINT_H

//Generic Functions
void print_point(Point* point);
Point* new_point(double x, double y, double z);
int line_length(Point* src, Point* dest);
void apply_matrix(Point* point, double* m);
void point_to_screen(Point* point, Point* center);
void lerp(Point* src, Point* dest, Point* result, double amt);
Point* cross_product(Point* point_a, Point* point_b);
double scalar_product(Point* point_a, Point* point_b);
void set_point(Point* point, double x, double y, double z);
void normalize(Point* point);
void convert_tangent_normal(Point* tangent_normal, Point* barycentric,
            Point* result, double* matrix, Vertex* a, Vertex* b, Vertex* c);
void cartesian_to_barycentric(Point* cart, Point* result,
                                                Point* a, Point* b, Point* c);
void barycentric_to_cartesian(Point* bary, Point* result,
                                                Point* a, Point* b, Point* c);
void Point_clone(Point* point, Point* new_point);
double compute_reflection(Point* normal, Point* light_direction,
                        Point* camera_direction, double specular_power);
void to_barycentric_clip(Point* bary, Point* a_v, Point* b_v, Point* c_v);

//Class Methods
VALUE C_Point_allocate(VALUE klass);
VALUE C_Point_dup(VALUE self);
VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z);
VALUE C_Point_x(VALUE self);
VALUE C_Point_y(VALUE self);
VALUE C_Point_z(VALUE self);
VALUE C_Point_q(VALUE self);
VALUE C_Point_x_set(VALUE self, VALUE value);
VALUE C_Point_y_set(VALUE self, VALUE value);
VALUE C_Point_z_set(VALUE self, VALUE value);
VALUE C_Point_minus(VALUE self, VALUE rb_other);
VALUE C_Point_plus(VALUE self, VALUE rb_other);
VALUE C_Point_normalize(VALUE self);
VALUE C_Point_round(VALUE self);
VALUE C_Point_to_barycentric(VALUE self, VALUE rb_verts);
VALUE C_Point_to_barycentric_clip(VALUE self, VALUE rb_verts);
VALUE C_Point_to_cartesian(VALUE self, VALUE rb_verts);
VALUE C_Point_to_cartesian_screen(VALUE self, VALUE rb_verts);
VALUE C_Point_to_screen(VALUE self, VALUE rb_center);
VALUE C_Point_to_texture(VALUE self, VALUE rb_verts, VALUE rb_size);
VALUE C_Point_apply_matrix(VALUE self, VALUE rb_matrix);
VALUE C_Point_apply_tangent_matrix(VALUE self, VALUE rb_tbn);
VALUE C_Point_scale_by_factor(VALUE self, VALUE value);
VALUE C_Point_cross_product(VALUE self, VALUE rb_other);
VALUE C_Point_scalar_product(VALUE self, VALUE rb_other);
VALUE C_Point_compute_reflection(VALUE self, VALUE rb_light_direction,
                        VALUE rb_camera_direction, VALUE rb_specular_power);
VALUE C_Point_equals(VALUE self, VALUE rb_other);
VALUE C_Point_contains_negative(VALUE self);
VALUE C_Point_compare(VALUE self, VALUE rb_other);
VALUE C_Point_to_normal(VALUE self, VALUE rb_normal_matrix, VALUE rb_tangent_normal,
                        VALUE rb_tangents, VALUE rb_bitangents, VALUE rb_normals);

#endif
