#ifndef RENDERER_H
#define RENDERER_H

//Structs
typedef struct c_texture {
    char* asset_path;
    GLuint id;  //ID assigned to us by OpenGL
    GLsizei width;
    GLsizei height;
    int bytes_per_pixel;
    int pitch;  //width in bytes of each row of the image
    int buffer_size;
    uint8_t* buffer;
} Texture;

typedef struct c_point {
    int id;
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Point;

typedef struct c_vertex {
    Point v;    //Vertex
    Point uv;   //Texture Coordinate
    Point n;    //Normal Vector
    Point t;    //Tangent Vector
    Point b;    //Bitangent Vector
} Vertex;

typedef struct c_face {
    Vertex a;
    Vertex b;
    Vertex c;
} Face;

typedef struct c_model {
    char* asset_path;
    int face_count;
    int vertex_count;
    Face* faces;
} Model;

typedef struct c_object {
    //TODO: write code to free an object from memory
    char* object_name;
    Model* model;
    Texture* texture;
    Texture* normal_map;
    Texture* specular_map;
    GLuint shader_program; //ID assigned to our compiled shader by OpenGL
} Object;

//generic utility functions
char* construct_asset_path(char* object_name, char* filename);
void message_log(char* message, char* predicate);

#endif

