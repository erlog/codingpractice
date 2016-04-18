#include "ruby.h"
#include "stdio.h"

typedef struct c_point { double x; double y; double z; } Point;
typedef struct c_matrix { double m[16]; } Matrix;

VALUE C_Optimization = Qnil;
VALUE C_Point = Qnil;
VALUE C_Drawing = Qnil;
VALUE C_Matrix = Qnil;

VALUE RB_ZERO = INT2NUM(0);
VALUE RB_POS = INT2NUM(1);
VALUE RB_NEG = INT2NUM(-1);

void print_point(Point* point) {
    printf("C_Point: PointObject.new(%f, %f, %f)\r\n", point->x, point->y, point->z);
    return;
}

static double scalar_product(Point* point_a, Point* point_b) {
    double result = (point_a->x*point_b->x) + (point_a->y*point_b->y) + (point_a->z*point_b->z);
    return result;
}

void normalize(Point* point) {
    double length = sqrt( pow(point->x,2) + pow(point->y,2) + pow(point->z,2) );
    point->x /= length; point->y /= length; point->z /= length;
    return;
}

static Point* cross_product(Point* point_a, Point* point_b) {
    static Point* result; result = ALLOC(Point);
    result->x = (point_a->y * point_b->z) - (point_a->z * point_b->y);
    result->y = (point_a->z * point_b->x) - (point_a->x * point_b->z);
    result->z = (point_a->x * point_b->y) - (point_a->y * point_b->x);
    return result;
}

static void deallocate_struct(void* my_struct) {
    xfree(my_struct);
    return;
}

static VALUE C_Matrix_allocate(VALUE klass) {
    Matrix* matrix; matrix = ALLOC(Matrix);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, matrix);
}

static VALUE C_Matrix_initialize(VALUE self, VALUE rb_array) {
    Matrix* matrix; Data_Get_Struct(self, Matrix, matrix);
    int i;
    for(i = 0; i < 16; i++) {
        matrix->m[i] = NUM2DBL(rb_ary_entry(rb_array, i));
    }
    return self;
}

static VALUE C_Point_allocate(VALUE klass) {
    Point* point; point = ALLOC(Point);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, point);
}

static VALUE C_Point_dup(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* new_point; new_point = ALLOC(Point);
    new_point->x = point->x; new_point->y = point->y; new_point->z = point->z;
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, new_point);
}

static VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = NUM2DBL(x); point->y = NUM2DBL(y); point->z = NUM2DBL(z);
    return self;
}

static VALUE C_Point_x(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->x);
}
static VALUE C_Point_y(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->y);
}
static VALUE C_Point_z(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->z);
}

static VALUE C_Point_x_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->x = NUM2DBL(value);
    return self;
}
static VALUE C_Point_y_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->y = NUM2DBL(value);
    return self;
}
static VALUE C_Point_z_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point); point->z = NUM2DBL(value);
    return self;
}

static VALUE C_Point_minus(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    static Point* result; result = ALLOC(Point);
    result->x = point->x - other->x;
    result->y = point->y - other->y;
    result->z = point->z - other->z;
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, result);
}
static VALUE C_Point_plus(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    static Point* result; result = ALLOC(Point);
    result->x = point->x + other->x;
    result->y = point->y + other->y;
    result->z = point->z + other->z;
    return Data_Wrap_Struct(rb_class_of(self), NULL, deallocate_struct, result);
}

static VALUE C_Point_normalize(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    normalize(point);
    return self;
}

static VALUE C_Point_round(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = roundf(point->x);
    point->y = roundf(point->y);
    return self;
}

static VALUE C_Point_to_barycentric(VALUE self, VALUE rb_verts) {
    Point* cart; Data_Get_Struct(self, Point, cart);
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    Point* vec_one;
    vec_one = ALLOC(Point);
    vec_one->x = c->x - a->x; vec_one->y = b->x - a->x; vec_one->z = a->x - cart->x;
    Point* vec_two;
    vec_two = ALLOC(Point);
    vec_two->x = c->y - a->y; vec_two->y = b->y - a->y; vec_two->z = a->y - cart->y;
    Point* vec_u = cross_product(vec_one, vec_two);

    cart->x = 1.0 - ((vec_u->x + vec_u->y) / vec_u->z);
    cart->y = vec_u->y / vec_u->z;
    cart->z = vec_u->x / vec_u->z;
    return self;
}

static VALUE C_Point_to_cartesian(VALUE self, VALUE rb_verts) {
    Point* bary; Data_Get_Struct(self, Point, bary);
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    double x = (a->x * bary->x) + (b->x * bary->y) + (c->x * bary->z);
    double y = (a->y * bary->x) + (b->y * bary->y) + (c->y * bary->z);
    double z = (a->z * bary->x) + (b->z * bary->y) + (c->z * bary->z);
    bary->x = x; bary->y = y; bary->z = z;
    return self;
}

static VALUE C_Point_to_screen(VALUE self, VALUE rb_center) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* center; Data_Get_Struct(rb_center, Point, center);

    point->x = roundf(center->x + (point->x * center->x));
    point->y = roundf(center->y + (point->y * center->y));
    point->z = (center->z + (point->z * center->z));
    return self;
}

static VALUE C_Point_to_texture(VALUE self, VALUE rb_size) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* size; Data_Get_Struct(rb_size, Point, size);

    point->x = roundf(point->x * size->x);
    point->y = roundf(point->y * size->y);
    return self;
}

static VALUE C_Point_apply_matrix(VALUE self, VALUE rb_matrix) {
    Point* point; Data_Get_Struct(self, Point, point);
    Matrix* matrix_struct; Data_Get_Struct(rb_matrix, Matrix, matrix_struct);
    double* matrix = matrix_struct->m;
    double x = (matrix[0] * point->x) + (matrix[1] * point->y) + (matrix[2] * point->z) + matrix[3];
    double y = (matrix[4] * point->x) + (matrix[5] * point->y) + (matrix[6] * point->z) + matrix[7];
    double z = (matrix[8] * point->x) + (matrix[9] * point->y) + (matrix[10] * point->z) + matrix[11];
    double d = (matrix[12] * point->x) + (matrix[13] * point->y) + (matrix[14] * point->z) + matrix[15];
    point->x = x/d; point->y = y/d; point->z = z/d;
    return self;
}

static VALUE C_Point_apply_tangent_matrix(VALUE self, VALUE rb_tbn) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* tangent; Data_Get_Struct(rb_ary_entry(rb_tbn, 0), Point, tangent);
    Point* bitangent; Data_Get_Struct(rb_ary_entry(rb_tbn, 1), Point, bitangent);
    Point* normal; Data_Get_Struct(rb_ary_entry(rb_tbn, 2), Point, normal);

    double x = (tangent->x * point->x) + (bitangent->x * point->y) + (normal->x * point->z);
    double y = (tangent->y * point->x) + (bitangent->y * point->y) + (normal->y * point->z);
    double z = (tangent->z * point->x) + (bitangent->z * point->y) + (normal->z * point->z);

    point->x = x; point->y = y; point->z = z;
    return self;
}

static VALUE C_Point_scale_by_factor(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    double factor = NUM2DBL(value);
    point->x *= factor; point->y *= factor; point->z *= factor;
    return self;
}

static VALUE C_Point_cross_product(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    Point* result = cross_product(point, other);
    *point = *result;
    return self;
}

static VALUE C_Point_scalar_product(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    double result = scalar_product(point, other);
    return DBL2NUM(result);
}

static VALUE C_Point_compute_reflection(VALUE self, VALUE rb_light_direction) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* light_direction; Data_Get_Struct(rb_light_direction, Point, light_direction);

    double factor = scalar_product(point, light_direction) * -2;
    point->x = (point->x * factor) + light_direction->x;
    point->y = (point->y * factor) + light_direction->y;
    point->z = (point->z * factor) + light_direction->z;
    normalize(point);
    return self;
}

static VALUE C_Point_equals(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    if( (point->x == other->x) && (point->y == other->y) || (point->z == other->z) ) {
        return Qtrue;
    }

    return Qfalse;
}

static VALUE C_Point_contains_negative(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);

    if( (point->x <= 0) || (point->y <= 0) || (point->z <= 0) ) {
        return Qtrue;
    }
    return Qfalse;
}

static VALUE C_Point_compare(VALUE self, VALUE rb_other) {
    Point* point; Data_Get_Struct(self, Point, point);
    Point* other; Data_Get_Struct(rb_other, Point, other);
    if( point->y < other->y) { return RB_POS; }
    if( point->y > other->y) { return RB_NEG; }
    if( point->x < other->x) { return RB_NEG; }
    if( point->x > other->x) { return RB_POS; }
    return RB_ZERO;
}

static VALUE C_lerp(VALUE self, VALUE rb_src, VALUE rb_dest, VALUE rb_amt) {
    Point* src; Data_Get_Struct(rb_src, Point, src);
    Point* dest; Data_Get_Struct(rb_dest, Point, dest);
    double amt = NUM2DBL(rb_amt);

    Point* new_point; new_point = ALLOC(Point);
    new_point->x = src->x + ( (dest->x - src->x) * amt );
    new_point->y = src->y + ( (dest->y - src->y) * amt );
    new_point->z = src->z + ( (dest->z - src->z) * amt );

    return Data_Wrap_Struct(rb_class_of(rb_src), NULL, deallocate_struct, new_point);
}

static VALUE C_should_not_draw_triangle(VALUE self, VALUE rb_a, VALUE rb_b, VALUE rb_c) {
    Point* a; Data_Get_Struct(rb_a, Point, a);
    Point* b; Data_Get_Struct(rb_b, Point, b);
    Point* c; Data_Get_Struct(rb_c, Point, c);

    double area = ( (a->x*b->y) + (b->x*c->y) +
                    (c->x*a->y) - (a->y*b->x) -
                    (b->y*c->x) - (c->y*a->x) );

    if(area == 0) { return Qtrue; }

    return Qfalse;
}

void Init_c_optimization() {
    C_Optimization = rb_define_module("C_Optimization");
    rb_define_module_function(C_Optimization, "lerp", C_lerp, 3);
    rb_define_module_function(C_Optimization, "should_not_draw_triangle", C_should_not_draw_triangle, 3);

    C_Matrix = rb_define_class_under(C_Optimization, "C_Matrix", rb_cObject);
    rb_define_alloc_func(C_Matrix, C_Matrix_allocate);
    rb_define_method(C_Matrix, "initialize", C_Matrix_initialize, 1);

    C_Point = rb_define_class_under(C_Optimization, "Point", rb_cObject);
    rb_define_alloc_func(C_Point, C_Point_allocate);
    rb_define_method(C_Point, "initialize", C_Point_initialize, 3);
    rb_define_method(C_Point, "dup", C_Point_dup, 0);
    rb_define_method(C_Point, "x", C_Point_x, 0);
    rb_define_method(C_Point, "y", C_Point_y, 0);
    rb_define_method(C_Point, "z", C_Point_z, 0);
    rb_define_method(C_Point, "x=", C_Point_x_set, 1);
    rb_define_method(C_Point, "y=", C_Point_y_set, 1);
    rb_define_method(C_Point, "z=", C_Point_z_set, 1);
    rb_define_method(C_Point, "==", C_Point_equals, 1);
    rb_define_alias(C_Point, "eql?", "==");
    rb_define_method(C_Point, "-", C_Point_minus, 1);
    rb_define_method(C_Point, "+", C_Point_minus, 1);
    rb_define_method(C_Point, "normalize!", C_Point_normalize, 0);
    rb_define_method(C_Point, "round!", C_Point_round, 0);
    rb_define_method(C_Point, "to_barycentric!", C_Point_to_barycentric, 1);
    rb_define_method(C_Point, "to_cartesian!", C_Point_to_cartesian, 1);
    rb_define_method(C_Point, "to_screen!", C_Point_to_screen, 1);
    rb_define_method(C_Point, "to_texture!", C_Point_to_texture, 1);
    rb_define_method(C_Point, "apply_matrix!", C_Point_apply_matrix, 1);
    rb_define_method(C_Point, "apply_tangent_matrix!", C_Point_apply_tangent_matrix, 1);
    rb_define_method(C_Point, "scale_by_factor!", C_Point_scale_by_factor, 1);
    rb_define_method(C_Point, "cross_product!", C_Point_cross_product, 1);
    rb_define_method(C_Point, "scalar_product", C_Point_scalar_product, 1);
    rb_define_method(C_Point, "<=>", C_Point_compare, 1);
    rb_define_method(C_Point, "contains_negative?", C_Point_contains_negative, 0);
    rb_define_method(C_Point, "compute_reflection!", C_Point_compute_reflection, 1);

}

