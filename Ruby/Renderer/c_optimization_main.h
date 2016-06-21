#ifndef C_OPTIMIZATION_MAIN_H
#define C_OPTIMIZATION_MAIN_H

//Project Structs
typedef struct c_point { float x; float y; float z; float q;} Point;
typedef struct c_matrix { float m[16]; } Matrix;
typedef struct c_vertex { Point* v; Point* screen_v; Point* uv;
                    Point* normal; Point* tangent; Point* bitangent;} Vertex;
typedef struct c_face { Vertex* a; Vertex* b; Vertex* c;} Face;
typedef struct c_zbuffer { int width; int height; float* buffer;
                           int drawn_pixels; int oob_pixels;
                           int occluded_pixels; } ZBuffer;

//Ruby Modules and Classes
extern VALUE C_Optimization;
extern VALUE C_Point;
extern VALUE C_Bitmap;
extern VALUE C_ZBuffer;
extern VALUE C_NormalMap;
extern VALUE C_SpecularMap;
extern VALUE C_Face;

//Ruby Constants
extern VALUE RB_ZERO;
extern VALUE RB_POS;
extern VALUE RB_NEG;

//Generic Functions
void Init_c_optimization();
void sort_floats(float* a, float* b);
float clamp(float value, float min, float max);

//Generic Class Methods
void deallocate_struct(void* my_struct);


#endif
