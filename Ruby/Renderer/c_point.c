#include "ruby.h"
#include "stdbool.h"

#include "c_optimization_main.h"
#include "c_wavefront.h"
#include "c_point.h"

void to_barycentric_clip(Point* bary, Point* a_v, Point* b_v, Point* c_v) {
    float x = bary->x/a_v->q;
    float y = bary->y/b_v->q;
    float z = bary->z/c_v->q;
    float total = x + y + z;
    bary->x = x/total;
    bary->y = y/total;
    bary->z = z/total;
    return;
}

float compute_reflection(Point* normal, Point* light_direction,
                        Point* camera_direction, float specular_power) {
    Point new_point;
    float factor = scalar_product(normal, light_direction) * -2;
    new_point.x = (normal->x * factor) + normal->x;
    new_point.y = (normal->y * factor) + normal->y;
    new_point.z = (normal->z * factor) + normal->z;
    normalize(&new_point);
    float reflectivity = clamp((scalar_product(&new_point, camera_direction)*-1), 0.0, 1.0);
    return pow(reflectivity, specular_power);
}

void convert_tangent_normal(Point* tangent_normal, Point* barycentric,
            Point* result, float* matrix, Vertex* a, Vertex* b, Vertex* c) {
    Point tangent; Point bitangent; Point normal;

    barycentric_to_cartesian(barycentric, &tangent,
                                        a->tangent, b->tangent, c->tangent);
    barycentric_to_cartesian(barycentric, &bitangent,
                                    a->bitangent, b->bitangent, c->bitangent);
    barycentric_to_cartesian(barycentric, &normal,
                                        a->normal, b->normal, c->normal);
    result->x = (tangent.x * tangent_normal->x) +
                (bitangent.x * tangent_normal->y) +
                (normal.x * tangent_normal->z);
    result->y = (tangent.y * tangent_normal->x) +
                (bitangent.y * tangent_normal->y) +
                (normal.y * tangent_normal->z);
    result->z = (tangent.z * tangent_normal->x) +
                (bitangent.z * tangent_normal->y) +
                (normal.z * tangent_normal->z);

    apply_matrix(result, matrix);
    normalize(result);

    return;
}

void point_to_screen(Point* point, Point* center) {
    point->x = roundf(center->x + (point->x * center->y));
    point->y = roundf(center->y + (point->y * center->y));
    point->z = center->z + (point->z * center->z);
    return;
}

void point_to_texture(Point* point, Point* result, Point* texture_size,
                                                Point* a, Point* b, Point* c) {
    barycentric_to_cartesian(point, result, a, b, c);
    result->x = roundf(result->x * texture_size->x);
    result->y = roundf(result->y * texture_size->y);
    result->z = 0.0;
    return;
}

void set_point(Point* point, float x, float y, float z) {
    point->x = x; point->y = y; point->z = z;
    return;
}


int line_length(Point* src, Point* dest) {
    return (int)sqrt(powf(dest->x - src->x,2) + powf(dest->y - src->y,2)) + 1;
}

void lerp(Point* src, Point* dest, Point* result, float amt) {
    result->x = src->x + ( (dest->x - src->x) * amt );
    result->y = src->y + ( (dest->y - src->y) * amt );
    result->z = src->z + ( (dest->z - src->z) * amt );
    return;
}

void print_point(Point* point) {
    printf("C_Point: Point(%f, %f, %f, %f)\r\n", point->x, point->y, point->z, point->q);
    return;
}

float scalar_product(Point* point_a, Point* point_b) {
    float result = (point_a->x*point_b->x) +
                    (point_a->y*point_b->y) +
                    (point_a->z*point_b->z);
    return result;
}

void normalize(Point* point) {
    float length = sqrtf( pow(point->x,2) +
                    pow(point->y,2) +
                    pow(point->z,2) );
    point->x /= length; point->y /= length; point->z /= length;
    return;
}

void cartesian_to_barycentric(Point* cart, Point* result,
                                                Point* a, Point* b, Point* c) {
    Point vec_one; Point vec_two;
    vec_one.x = c->x - a->x; vec_one.y = b->x - a->x; vec_one.z = a->x - cart->x;
    vec_two.x = c->y - a->y; vec_two.y = b->y - a->y; vec_two.z = a->y - cart->y;
    Point vec_u = cross_product(&vec_one, &vec_two);

    float x = clamp(1.0 - ((vec_u.x + vec_u.y) / vec_u.z), 0.0, 1.0);
    float y = clamp(vec_u.y / vec_u.z, 0.0, 1.0);
    float z = clamp(vec_u.x / vec_u.z, 0.0, 1.0);
    float total = x + y + z;

    result->x = x/total; result->y = y/total; result->z = z/total;
    return;
}

void barycentric_to_cartesian(Point* bary, Point* result,
                                                Point* a, Point* b, Point* c) {
    float x = (a->x * bary->x) + (b->x * bary->y) + (c->x * bary->z);
    float y = (a->y * bary->x) + (b->y * bary->y) + (c->y * bary->z);
    float z = (a->z * bary->x) + (b->z * bary->y) + (c->z * bary->z);
    result->x = x; result->y = y; result->z = z;
    return;
}

void apply_matrix(Point* point, float* m) {
    float x = (m[0] * point->x) + (m[1] * point->y) + (m[2] * point->z) + m[3];
    float y = (m[4] * point->x) + (m[5] * point->y) + (m[6] * point->z) + m[7];
    float z = (m[8] * point->x) + (m[9] * point->y) + (m[10] * point->z) + m[11];
    float q = (m[12] * point->x) + (m[13] * point->y) + (m[14] * point->z) + m[15];
    point->x = x/q; point->y = y/q; point->z = z/q; point->q = q;
    return;
}

bool does_not_contain_negative(Point* point) {
    if( (point->x <= 0) || (point->y <= 0) || (point->z <= 0) ) {
        return false;
    }
    return true;
}

inline Point cross_product(Point* point_a, Point* point_b) {
    Point result = {
     (point_a->y * point_b->z) - (point_a->z * point_b->y),
     (point_a->z * point_b->x) - (point_a->x * point_b->z),
     (point_a->x * point_b->y) - (point_a->y * point_b->x) };
    return result;
}

VALUE C_Point_allocate(VALUE klass) {
    Point* point; point = ALLOC(Point);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, point);
}

inline void Point_clone(Point* point, Point* new_point) {
    new_point->x = point->x; new_point->y = point->y; new_point->z = point->z;
    return;
}

VALUE C_Point_dup(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* new_point; new_point = ALLOC(Point);
    Point_clone(point, new_point);
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, new_point);
}

VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = NUM2DBL(x); point->y = NUM2DBL(y); point->z = NUM2DBL(z);
    point->q = 1.0;
    return self;
}

VALUE C_Point_x(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->x);
}
VALUE C_Point_y(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->y);
}
VALUE C_Point_z(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->z);
}
VALUE C_Point_q(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->q);
}

VALUE C_Point_x_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->x = NUM2DBL(value);
    return self;
}
VALUE C_Point_y_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->y = NUM2DBL(value);
    return self;
}
VALUE C_Point_z_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->z = NUM2DBL(value);
    return self;
}

VALUE C_Point_minus(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    Point* result; result = ALLOC(Point);
    result->x = point->x - other->x;
    result->y = point->y - other->y;
    result->z = point->z - other->z;
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, result);
}
VALUE C_Point_plus(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    Point* result; result = ALLOC(Point);
    result->x = point->x + other->x;
    result->y = point->y + other->y;
    result->z = point->z + other->z;
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, result);
}

VALUE C_Point_normalize(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    normalize(point);
    return self;
}

VALUE C_Point_round(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = roundf(point->x);
    point->y = roundf(point->y);
    return self;
}

VALUE C_Point_to_barycentric(VALUE self, VALUE rb_verts) {
    Point* cart; Data_Get_Struct(self, Point, cart);
    Point* a; Point* b; Point* c;
    Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    cartesian_to_barycentric(cart, cart, a, b, c);
    return self;
}

VALUE C_Point_to_barycentric_clip(VALUE self, VALUE rb_verts) {
    Point* bary; Data_Get_Struct(self, Point, bary);
    Point* a; Point* b; Point* c;
    Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    to_barycentric_clip(bary, a, b, c);
    return self;
}

VALUE C_Point_to_cartesian(VALUE self, VALUE rb_verts) {
    Point* bary; Data_Get_Struct(self, Point, bary);
    Point* a; Point* b; Point* c;
    Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    barycentric_to_cartesian(bary, bary, a, b, c);
    return self;
}

VALUE C_Point_to_cartesian_screen(VALUE self, VALUE rb_verts) {
    Point* bary; Data_Get_Struct(self, Point, bary);
    Point* a; Point* b; Point* c;
    Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);
    Point* new_point; new_point = ALLOC(Point);

    new_point->x = roundf((a->x * bary->x) + (b->x * bary->y) + (c->x * bary->z));
    new_point->y = roundf((a->y * bary->x) + (b->y * bary->y) + (c->y * bary->z));
    new_point->z = (a->z * bary->x) + (b->z * bary->y) + (c->z * bary->z);

    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, new_point);
}

VALUE C_Point_to_screen(VALUE self, VALUE rb_center) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* center; Data_Get_Struct(rb_center, Point, center);
    //using center->y both times gives us horiz+ rendering instead of vert-
    point_to_screen(point, center);
    return self;
}

VALUE C_Point_to_texture(VALUE self, VALUE rb_verts, VALUE rb_size) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* size; Data_Get_Struct(rb_size, Point, size);
    Point* a; Point* b; Point* c;
    Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    Point* new_point; new_point = ALLOC(Point);
    point_to_texture(point, new_point, size, a, b, c);
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, new_point);
}

VALUE C_Point_to_normal(VALUE self, VALUE rb_normal_matrix, VALUE rb_tangent_normal,
                        VALUE rb_tangents, VALUE rb_bitangents, VALUE rb_normals) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* tangent_normal; Data_Get_Struct(rb_tangent_normal, Point, tangent_normal);
    Point* a; Point* b; Point* c;

    Matrix* matrix_struct;
    Data_Get_Struct(rb_normal_matrix, Matrix, matrix_struct);
    float* matrix = matrix_struct->m;

    Data_Get_Struct(rb_ary_entry(rb_tangents, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_tangents, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_tangents, 2), Point, c);
    Point tangent;
    barycentric_to_cartesian(point, &tangent, a, b, c);

    Data_Get_Struct(rb_ary_entry(rb_bitangents, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_bitangents, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_bitangents, 2), Point, c);
    Point bitangent;
    barycentric_to_cartesian(point, &bitangent, a, b, c);

    Data_Get_Struct(rb_ary_entry(rb_normals, 0), Point, a);
    Data_Get_Struct(rb_ary_entry(rb_normals, 1), Point, b);
    Data_Get_Struct(rb_ary_entry(rb_normals, 2), Point, c);
    Point normal;
    barycentric_to_cartesian(point, &normal, a, b, c);

    Point* result; result = ALLOC(Point);
    result->x = (tangent.x * tangent_normal->x) +
                (bitangent.x * tangent_normal->y) +
                (normal.x * tangent_normal->z);
    result->y = (tangent.y * tangent_normal->x) +
                (bitangent.y * tangent_normal->y) +
                (normal.y * tangent_normal->z);
    result->z = (tangent.z * tangent_normal->x) +
                (bitangent.z * tangent_normal->y) +
                (normal.z * tangent_normal->z);

    apply_matrix(result, matrix);
    normalize(result);
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, result);
}

VALUE C_Point_apply_matrix(VALUE self, VALUE rb_matrix) {
    Point* point; Data_Get_Struct(self, Point, point);
    Matrix* matrix_struct; Data_Get_Struct(rb_matrix, Matrix, matrix_struct);
    float* m = matrix_struct->m; apply_matrix(point, m);
    return self;
}

VALUE C_Point_scale_by_factor(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    float factor = NUM2DBL(value);
    point->x *= factor; point->y *= factor; point->z *= factor;
    return self;
}

VALUE C_Point_cross_product(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    *point = cross_product(point, other);
    return self;
}

VALUE C_Point_scalar_product(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    float result = scalar_product(point, other);
    return DBL2NUM(result);
}

VALUE C_Point_compute_reflection(VALUE self, VALUE rb_light_direction,
                        VALUE rb_camera_direction, VALUE rb_specular_power) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* light_direction; Data_Get_Struct(rb_light_direction, Point, light_direction);
    Point* camera_direction; Data_Get_Struct(rb_camera_direction, Point, camera_direction);
    float specular_power = NUM2DBL(rb_specular_power);

    float reflectivity =
    compute_reflection(point, light_direction, camera_direction, specular_power);

    return DBL2NUM(reflectivity);
}

VALUE C_Point_equals(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    if( (point->x == other->x) && (point->y == other->y) && (point->z == other->z) ) {
        return Qtrue;
    }

    return Qfalse;
}

VALUE C_Point_contains_negative(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);

    if( (point->x <= 0) || (point->y <= 0) || (point->z <= 0) ) {
        return Qtrue;
    }
    return Qfalse;
}

VALUE C_Point_compare(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    if( point->y < other->y) { return RB_POS; }
    if( point->y > other->y) { return RB_NEG; }
    if( point->x < other->x) { return RB_NEG; }
    if( point->x > other->x) { return RB_POS; }
    return RB_ZERO;
}
