#include "ruby.h"
#include "stdio.h"

VALUE C_Optimization = Qnil;

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
    rb_define_method(C_Optimization, "barycentric_to_cartesian",
                         method_barycentric_to_cartesian, -1);
}

/**
 * def to_cartesian(verts)
    x = (verts[0].x * @x) + (verts[1].x * @y) + (verts[2].x * @z)
    y = (verts[0].y * @x) + (verts[1].y * @y) + (verts[2].y * @z)
    z = (verts[0].z * @x) + (verts[1].z * @y) + (verts[2].z * @z)
    return PointObject.new(x, y, z)
end
**/

