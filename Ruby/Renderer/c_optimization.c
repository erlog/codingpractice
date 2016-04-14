#include "ruby.h"
#include "stdio.h"

typedef struct c_point { double x; double y; double z; } Point;

VALUE C_Optimization = Qnil;
VALUE C_Point = Qnil;

void print_point(double* point) {
    printf("C_Point: PointObject.new(%f, %f, %f)\r\n", point[0], point[1], point[2]);
    return;
}

double* cross_product(double* point_a, double* point_b) {
    double* result = malloc(sizeof(double)*3);
    result[0] = (point_a[1] * point_b[2]) - (point_a[2] * point_b[1]);
    result[1] = (point_a[2] * point_b[0]) - (point_a[0] * point_b[2]);
    result[2] = (point_a[0] * point_b[1]) - (point_a[1] * point_b[0]);
    return result;
}

VALUE array_to_point(double x, double y, double z) {
    VALUE result[3];
    result[0] = DBL2NUM(x);
    result[1] = DBL2NUM(y);
    result[2] = DBL2NUM(z);
    return rb_ary_new4(3, result);
}

double* point_to_array(VALUE rb_point_array) {
    double* point = malloc(sizeof(double)*3);
    point[0] = NUM2DBL(rb_ary_entry(rb_point_array, 0));
    point[1] = NUM2DBL(rb_ary_entry(rb_point_array, 1));
    point[2] = NUM2DBL(rb_ary_entry(rb_point_array, 2));
    return point;
}


VALUE method_normalize(VALUE self, VALUE rb_xyz) {
    double* xyz = point_to_array(rb_xyz);
    double length = sqrt( pow(xyz[0],2) + pow(xyz[1],2) + pow(xyz[2],2) );

    return array_to_point(xyz[0]/length, xyz[1]/length, xyz[2]/length);
}

static void C_Point_deallocate(void* point) {
    xfree(point);
    return;
}

static VALUE C_Point_allocate(VALUE klass) {
    Point* point;
    point = ALLOC(Point);
    return Data_Wrap_Struct(klass, NULL, C_Point_deallocate, point);
}

static VALUE C_Point_initialize(VALUE self, VALUE rb_ary_point) {
    Check_Type(rb_ary_point, T_ARRAY);
    double* value = point_to_array(rb_ary_point);

    Point* point;
    Data_Get_Struct(self, Point, point);

    point->x = value[0]; point->y = value[1]; point->z = value[2];

    return self;
}

static VALUE C_Point_x(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    return DBL2NUM(point->x);
}
static VALUE C_Point_y(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    return DBL2NUM(point->y);
}
static VALUE C_Point_z(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    return DBL2NUM(point->z);
}

static VALUE C_Point_x_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = NUM2DBL(value);
    return self;
}
static VALUE C_Point_y_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->y = NUM2DBL(value);
    return self;
}
static VALUE C_Point_z_set(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->z = NUM2DBL(value);
    return self;
}

static VALUE C_Point_normalize(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    double length = sqrt( pow(point->x,2) + pow(point->y,2) + pow(point->z,2) );
    point->x = point->x/length;
    point->y = point->y/length;
    point->z = point->z/length;
    return self;
}

VALUE C_Point_to_barycentric(VALUE self, VALUE rb_verts) {
    Point* cart; Data_Get_Struct(self, Point, cart);
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    double vec_one[3];
    vec_one[0] = c->x - a->x; vec_one[1] = b->x - a->x; vec_one[2] = a->x - cart->x;
    double vec_two[3];
    vec_two[0] = c->y - a->y; vec_two[1] = b->y - a->y; vec_two[2] = a->y - cart->y;
    double* vec_u = cross_product(vec_one, vec_two);

    cart->x = 1.0 - ((vec_u[0] + vec_u[1]) / vec_u[2]);
    cart->y = vec_u[1] / vec_u[2];
    cart->z = vec_u[0] / vec_u[2];
    return self;
}

VALUE C_Point_to_cartesian(VALUE self, VALUE rb_verts) {
    Point* bary; Data_Get_Struct(self, Point, bary);
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    double x = (a->x * bary->x) + (b->x * bary->y) + (c->x * bary->z);
    double y = (a->y * bary->x) + (b->y * bary->y) + (c->y * bary->z);
    double z = (a->z * bary->x) + (b->z * bary->y) + (c->z * bary->z);
    bary->x = x;
    bary->y = y;
    bary->z = z;
    return self;
}

void Init_c_optimization() {
    C_Optimization = rb_define_module("C_Optimization");
    C_Point = rb_define_class_under(C_Optimization, "Point", rb_cObject);
    rb_define_alloc_func(C_Point, C_Point_allocate);
    rb_define_method(C_Point, "initialize", C_Point_initialize, 1);
    rb_define_method(C_Point, "x", C_Point_x, 0);
    rb_define_method(C_Point, "u", C_Point_x, 0);
    rb_define_method(C_Point, "y", C_Point_y, 0);
    rb_define_method(C_Point, "v", C_Point_y, 0);
    rb_define_method(C_Point, "z", C_Point_z, 0);
    rb_define_method(C_Point, "x=", C_Point_x_set, 1);
    rb_define_method(C_Point, "y=", C_Point_y_set, 1);
    rb_define_method(C_Point, "z=", C_Point_z_set, 1);
    rb_define_method(C_Point, "normalize!", C_Point_normalize, 0);
    rb_define_method(C_Point, "to_barycentric!", C_Point_to_barycentric, 1);
    rb_define_method(C_Point, "to_cartesian!", C_Point_to_cartesian, 1);
}

