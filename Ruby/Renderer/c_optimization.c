#include "ruby.h"
#include "stdio.h"

VALUE C_Optimization = Qnil;

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

VALUE method_cartesian_to_barycentric(int argc, VALUE* c_args, VALUE self) {
    double* cart = point_to_array(c_args[0]);
    double* a = point_to_array(c_args[1]);
    double* b = point_to_array(c_args[2]);
    double* c = point_to_array(c_args[3]);

    double vec_one[3];
    double vec_two[3];
    vec_one[0] = c[0] - a[0]; vec_one[1] = b[0] - a[0]; vec_one[2] = a[0] - cart[0];
    vec_two[0] = c[1] - a[1]; vec_two[1] = b[1] - a[1]; vec_two[2] = a[1] - cart[1];
    double* vec_u = cross_product(vec_one, vec_two);

    return array_to_point( 1.0 - ((vec_u[0] + vec_u[1]) / vec_u[2]),
                           vec_u[1] / vec_u[2],
                           vec_u[0] / vec_u[2]);
}
VALUE method_barycentric_to_cartesian(int argc, VALUE* c_args, VALUE self) {
    double* bary = point_to_array(c_args[0]);
    double* a = point_to_array(c_args[1]);
    double* b = point_to_array(c_args[2]);
    double* c = point_to_array(c_args[3]);

    return array_to_point(
                (a[0] * bary[0]) + (b[0] * bary[1]) + (c[0] * bary[2]),
                (a[1] * bary[0]) + (b[1] * bary[1]) + (c[1] * bary[2]),
                (a[2] * bary[0]) + (b[2] * bary[1]) + (c[2] * bary[2]));
}

VALUE method_normalize(VALUE self, VALUE rb_xyz) {
    double* xyz = point_to_array(rb_xyz);
    double length = sqrt( pow(xyz[0],2) + pow(xyz[1],2) + pow(xyz[2],2) );

    return array_to_point(xyz[0]/length, xyz[1]/length, xyz[2]/length);
}

void Init_c_optimization() {
    C_Optimization = rb_define_module("C_Optimization");
    rb_define_method(C_Optimization, "c_barycentric_to_cartesian",
                         method_barycentric_to_cartesian, -1);
    rb_define_method(C_Optimization, "c_cartesian_to_barycentric",
                         method_cartesian_to_barycentric, -1);
    rb_define_method(C_Optimization, "c_normalize",
                         method_normalize, 1);
}

