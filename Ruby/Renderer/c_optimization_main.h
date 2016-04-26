#ifndef C_OPTIMIZATION_MAIN_H
#define C_OPTIMIZATION_MAIN_H

//Ruby Modules and Classes
extern VALUE C_Optimization;
extern VALUE C_Point;
extern VALUE C_Bitmap;
extern VALUE C_ZBuffer;
extern VALUE C_NormalMap;
extern VALUE C_SpecularMap;

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

//Structs
typedef struct c_matrix { double m[16]; } Matrix;
typedef struct c_point { double x; double y; double z; double q;} Point;
typedef struct c_vertex { Point* v; Point* screen_v; Point* uv;
                    Point* normal; Point* tangent; Point* bitangent;} Vertex;

#endif
