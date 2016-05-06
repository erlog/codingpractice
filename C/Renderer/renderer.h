#ifndef RENDERER_H
#define RENDERER_H

typedef union c_color { uint32_t bytes;
    struct { uint8_t r; uint8_t g; uint8_t b; uint8_t a;} rgba; } Color;
typedef struct c_bitmap { int width; int height; Color* buffer;
    int bytes_per_pixel; int bytes_per_row; } Bitmap;
typedef struct c_point { float x; float y; float z; float q;} Point;
typedef struct c_vertex { Point* v; Point* screen_v; Point* uv;
                    Point* normal; Point* tangent; Point* bitangent;} Vertex;
typedef struct c_face { Vertex* a; Vertex* b; Vertex* c;} Face;
typedef struct c_matrix { double m[16]; } Matrix;

#endif

