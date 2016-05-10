#ifndef RENDERER_H
#define RENDERER_H

//Structs
typedef struct c_texture { char* asset_path; GLuint texture_id; GLsizei width;
    int height; uint8_t* buffer; } Texture;
typedef struct c_point { int id; GLfloat x; GLfloat y; GLfloat z; GLfloat q; } Point;
typedef struct c_vertex { Point v; Point uv; Point n;} Vertex;
typedef struct c_face { Vertex a; Vertex b; Vertex c;} Face;
typedef struct c_model { char* asset_path; int face_count; Face* faces;} Model;
//TODO: write code to free an object from memory
typedef struct c_object { char* object_name; Model* model; Texture* texture; } Object;

//generic utility functions
char* construct_asset_path(char* object_name, char* filename);
void message_log(char* message);

#endif

