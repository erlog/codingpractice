#ifndef C_OPTIMIZATION_MAIN_H
#define C_OPTIMIZATION_MAIN_H

//Ruby Modules and Classes
VALUE C_Optimization;
VALUE C_Point;
VALUE C_Matrix;
VALUE C_Bitmap;
VALUE C_ZBuffer;

//Ruby Constants
VALUE RB_ZERO;
VALUE RB_POS;
VALUE RB_NEG;

//Generic Functions
void Init_c_optimization();
void sort_doubles(double* a, double* b);
inline double clamp(double value, double min, double max);

//Generic Class Methods
void deallocate_struct(void* my_struct);

//Small Classes and Class Methods
typedef struct c_matrix { double m[16]; } Matrix;
VALUE C_Matrix_allocate(VALUE klass);
VALUE C_Matrix_initialize(VALUE self, VALUE rb_array);

#endif
