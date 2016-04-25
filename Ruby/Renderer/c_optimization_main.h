#ifndef C_OPTIMIZATION_MAIN_H
#define C_OPTIMIZATION_MAIN_H

//Ruby Modules and Classes
extern VALUE C_Optimization;
extern VALUE C_Point;
extern VALUE C_Matrix;
extern VALUE C_Bitmap;
extern VALUE C_ZBuffer;
extern VALUE C_NormalMap;

//Ruby Constants
extern VALUE RB_ZERO;
extern VALUE RB_POS;
extern VALUE RB_NEG;

//Generic Functions
void Init_c_optimization();
void sort_doubles(double* a, double* b);
double clamp(double value, double min, double max);

//Generic Class Methods
void deallocate_struct(void* my_struct);

//Small Classes and Class Methods
typedef struct c_matrix { double m[16]; } Matrix;
VALUE C_Matrix_allocate(VALUE klass);
VALUE C_Matrix_initialize(VALUE self, VALUE rb_array);

#endif
