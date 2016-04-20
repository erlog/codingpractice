#ifndef C_POINT_H
#define C_POINT_H

//Ruby Class C Struct
typedef struct c_point { double x; double y; double z; } Point;

//Generic Functions
void print_point(Point* point);
int line_length(Point* src, Point* dest);
void lerp(Point* src, Point* dest, Point* result, double amt);
Point* cross_product(Point* point_a, Point* point_b);
double scalar_product(Point* point_a, Point* point_b);
void normalize(Point* point);

//Class Methods
VALUE C_Point_allocate(VALUE klass);
VALUE C_Point_dup(VALUE self);
VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z);
VALUE C_Point_x(VALUE self);
VALUE C_Point_y(VALUE self);
VALUE C_Point_z(VALUE self);
VALUE C_Point_x_set(VALUE self, VALUE value);
VALUE C_Point_y_set(VALUE self, VALUE value);
VALUE C_Point_z_set(VALUE self, VALUE value);
VALUE C_Point_minus(VALUE self, VALUE rb_other);
VALUE C_Point_plus(VALUE self, VALUE rb_other);
VALUE C_Point_normalize(VALUE self);
VALUE C_Point_round(VALUE self);
VALUE C_Point_to_barycentric(VALUE self, VALUE rb_verts);
VALUE C_Point_to_cartesian(VALUE self, VALUE rb_verts);
VALUE C_Point_to_cartesian_screen(VALUE self, VALUE rb_verts);
VALUE C_Point_to_screen(VALUE self, VALUE rb_center);
VALUE C_Point_to_texture(VALUE self, VALUE rb_size);
VALUE C_Point_apply_matrix(VALUE self, VALUE rb_matrix);
VALUE C_Point_apply_tangent_matrix(VALUE self, VALUE rb_tbn);
VALUE C_Point_scale_by_factor(VALUE self, VALUE value);
VALUE C_Point_cross_product(VALUE self, VALUE rb_other);
VALUE C_Point_scalar_product(VALUE self, VALUE rb_other);
VALUE C_Point_compute_reflection(VALUE self, VALUE rb_light_direction);
VALUE C_Point_equals(VALUE self, VALUE rb_other);
VALUE C_Point_contains_negative(VALUE self);
VALUE C_Point_compare(VALUE self, VALUE rb_other);

#endif
