#include "ruby.h"
#include "stdio.h"

VALUE C_Optimization = Qnil;

double* cross_product(double* point_a, double* point_b) {
    static double result[3];
    //x = (@y*other.z) - (@z*other.y)
    result[0] = (point_a[1] * point_b[2]) - (point_a[2] * point_b[1]);
    //y = (@z*other.x) - (@x*other.z)
    result[1] = (point_a[2] * point_b[0]) - (point_a[0] * point_b[2]);
    //z = (@x*other.y) - (@y*other.x)
    result[2] = (point_a[0] * point_b[1]) - (point_a[1] * point_b[0]);
    return result;
}

VALUE method_cartesian_to_barycentric(int argc, VALUE* c_args, VALUE self) {
    double cart_x = NUM2DBL(c_args[0]);
    double cart_y = NUM2DBL(c_args[1]);
    double cart_z = NUM2DBL(c_args[2]);
    double a_x = NUM2DBL(c_args[3]);
    double a_y = NUM2DBL(c_args[4]);
    double a_z = NUM2DBL(c_args[5]);
    double b_x = NUM2DBL(c_args[6]);
    double b_y = NUM2DBL(c_args[7]);
    double b_z = NUM2DBL(c_args[8]);
    double c_x = NUM2DBL(c_args[9]);
    double c_y = NUM2DBL(c_args[10]);
    double c_z = NUM2DBL(c_args[11]);

    //vec_one = PointObject.new(c.x-a.x, b.x-a.x, a.x-@x)
    //vec_two = PointObject.new(c.y-a.y, b.y-a.y, a.y-@y)
    //u = vec_one.cross_product!(vec_two)
    double vec_one[3];
    double vec_two[3];
    vec_one[0] = c_x - a_x; vec_one[1] = b_x - a_x; vec_one[2] = a_x - cart_x;
    vec_two[0] = c_y - a_y; vec_two[1] = b_y - a_y; vec_two[2] = a_y - cart_y;
    double* vec_u = cross_product(vec_one, vec_two);

    //x = 1.0 - ((u.x + u.y)/u.z.to_f)
    //y = u.y/u.z.to_f
    //z = u.x/u.z.to_f
    VALUE result[3];
    result[0] = DBL2NUM(1.0 - ((vec_u[0] + vec_u[1]) / vec_u[2]));
    result[1] = DBL2NUM(vec_u[1] / vec_u[2]);
    result[2] = DBL2NUM(vec_u[0] / vec_u[2]);
    return rb_ary_new4(3, result);
}
VALUE method_barycentric_to_cartesian(int argc, VALUE* c_args, VALUE self) {
    double bary_x = NUM2DBL(c_args[0]);
    double bary_y = NUM2DBL(c_args[1]);
    double bary_z = NUM2DBL(c_args[2]);
    double a_x = NUM2DBL(c_args[3]);
    double a_y = NUM2DBL(c_args[4]);
    double a_z = NUM2DBL(c_args[5]);
    double b_x = NUM2DBL(c_args[6]);
    double b_y = NUM2DBL(c_args[7]);
    double b_z = NUM2DBL(c_args[8]);
    double c_x = NUM2DBL(c_args[9]);
    double c_y = NUM2DBL(c_args[10]);
    double c_z = NUM2DBL(c_args[11]);

    VALUE cartesian[3];
    cartesian[0] = DBL2NUM((a_x * bary_x) + (b_x * bary_y) + (c_x * bary_z));
    cartesian[1] = DBL2NUM((a_y * bary_x) + (b_y * bary_y) + (c_y * bary_z));
    cartesian[2] = DBL2NUM((a_z * bary_x) + (b_z * bary_y) + (c_z * bary_z));
    return rb_ary_new4(3, cartesian);
}

void Init_c_optimization() {
    C_Optimization = rb_define_module("C_Optimization");
    rb_define_method(C_Optimization, "c_barycentric_to_cartesian",
                         method_barycentric_to_cartesian, -1);
    rb_define_method(C_Optimization, "c_cartesian_to_barycentric",
                         method_cartesian_to_barycentric, -1);
}

