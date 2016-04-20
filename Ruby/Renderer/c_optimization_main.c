#include "ruby.h"

#include "c_optimization_main.h"
#include "c_point.h"
#include "c_drawing.h"
#include "c_bitmap.h"

//Ruby Modules and Classes
VALUE C_Optimization = Qnil;
VALUE C_Point = Qnil;
VALUE C_Matrix = Qnil;

//Ruby Constants
VALUE RB_ZERO = INT2NUM(0);
VALUE RB_POS = INT2NUM(1);
VALUE RB_NEG = INT2NUM(-1);

void deallocate_struct(void* my_struct) {
    xfree(my_struct);
    return;
}

VALUE C_Matrix_allocate(VALUE klass) {
    Matrix* matrix; matrix = ALLOC(Matrix);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, matrix);
}

VALUE C_Matrix_initialize(VALUE self, VALUE rb_array) {
    Matrix* matrix; Data_Get_Struct(self, Matrix, matrix);
    int i;
    for(i = 0; i < 16; i++) {
        matrix->m[i] = NUM2DBL(rb_ary_entry(rb_array, i));
    }
    return self;
}

void sort_doubles(double* a, double* b) {
    double backup = *a;
    if (*a > *b) { *a = *b; *b = backup; }
    return;
}

void Init_c_optimization() {
    C_Optimization = rb_define_module("C_Optimization");
    rb_define_module_function(C_Optimization, "triangle", C_triangle, 1);

    C_ZBuffer = rb_define_class_under(C_Optimization, "Z_Buffer", rb_cObject);
    rb_define_alloc_func(C_ZBuffer, C_ZBuffer_allocate);
    rb_define_method(C_ZBuffer, "initialize", C_ZBuffer_initialize, 2);
    rb_define_method(C_ZBuffer, "should_draw?", C_ZBuffer_should_draw, 1);
    rb_define_method(C_ZBuffer, "drawn_pixels", C_ZBuffer_drawn_pixels, 0);
    rb_define_method(C_ZBuffer, "oob_pixels", C_ZBuffer_oob_pixels, 0);
    rb_define_method(C_ZBuffer, "occluded_pixels", C_ZBuffer_occluded_pixels, 0);

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
    rb_define_method(C_Point, "+", C_Point_plus, 1);
    rb_define_method(C_Point, "normalize!", C_Point_normalize, 0);
    rb_define_method(C_Point, "round!", C_Point_round, 0);
    rb_define_method(C_Point, "to_barycentric!", C_Point_to_barycentric, 1);
    rb_define_method(C_Point, "to_cartesian!", C_Point_to_cartesian, 1);
    rb_define_method(C_Point, "to_cartesian_screen", C_Point_to_cartesian_screen, 1);
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

