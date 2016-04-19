#ifndef C_OPTIMIZATION_MAIN_H
#define C_OPTIMIZATION_MAIN_H

//Ruby Modules and Classes
VALUE C_Optimization;
VALUE C_Point;
VALUE C_Matrix;

//Ruby Constants
VALUE RB_ZERO;
VALUE RB_POS;
VALUE RB_NEG;

//Generic Class Methods
void deallocate_struct(void* my_struct);

//Small Classes and Class Methods
typedef struct c_matrix { double m[16]; } Matrix;
VALUE C_Matrix_allocate(VALUE klass);
VALUE C_Matrix_initialize(VALUE self, VALUE rb_array);

//Generic Ruby Functions
VALUE C_lerp(VALUE self, VALUE rb_src, VALUE rb_dest, VALUE rb_amt);
VALUE C_should_not_draw_triangle(VALUE self, VALUE rb_a, VALUE rb_b, VALUE rb_c);

//Generic Functions
void Init_c_optimization();

#endif
