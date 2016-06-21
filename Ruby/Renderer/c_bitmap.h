#ifndef C_BITMAP_H
#define C_BITMAP_H
#include "stdbool.h"

//utility functions
inline int32_t color_to_bgr(int r, int g, int b);

//generic functions
VALUE C_color_multiply(VALUE self, VALUE rb_color_int, VALUE rb_factor);
inline int32_t color_multiply(int32_t color, float factor);

//Bitmap class
typedef struct c_bitmap { int width; int height; int32_t* buffer; } Bitmap;
void deallocate_bitmap(Bitmap* bitmap);
VALUE C_Bitmap_allocate(VALUE klass);
VALUE C_Bitmap_initialize(VALUE self, VALUE rb_width, VALUE rb_height, VALUE rb_color);
VALUE C_Bitmap_set_pixel(VALUE self, VALUE rb_point, VALUE rb_color);
VALUE C_Bitmap_get_pixel(VALUE self, VALUE rb_point);
VALUE C_Bitmap_write_to_file(VALUE self, VALUE rb_path);
VALUE C_Bitmap_dimensions(VALUE self);
VALUE C_Bitmap_width(VALUE self);
VALUE C_Bitmap_height(VALUE self);
int32_t bitmap_get_pixel(Bitmap* bitmap, Point* point);
void bitmap_set_pixel(Bitmap* bitmap, Point* point, int32_t color);

void deallocate_zbuffer(ZBuffer* zbuffer);
VALUE C_ZBuffer_allocate(VALUE klass);
VALUE C_ZBuffer_initialize(VALUE self, VALUE rb_width, VALUE rb_height);
VALUE C_ZBuffer_set_point(VALUE self, VALUE rb_point);
VALUE C_ZBuffer_get_point(VALUE self, VALUE rb_point);
VALUE C_ZBuffer_drawn_pixels(VALUE self);
VALUE C_ZBuffer_oob_pixels(VALUE self);
VALUE C_ZBuffer_occluded_pixels(VALUE self);
VALUE C_ZBuffer_should_draw(VALUE self, VALUE rb_point);
bool zbuffer_should_draw(ZBuffer* zbuffer, Point* point);

//TangentSpaceNormalMap
typedef struct c_normalmap { int width; int height; Point* buffer; } NormalMap;
void deallocate_normalmap(NormalMap* normalmap);
VALUE C_NormalMap_allocate(VALUE klass);
VALUE C_NormalMap_initialize(VALUE self, VALUE rb_bitmap);
VALUE C_NormalMap_get_normal(VALUE self, VALUE rb_point);
inline Point* get_normal(NormalMap* normalmap, Point* point);

//SpecularMap
typedef struct c_specularmap { int width; int height; float* buffer; } SpecularMap;
void deallocate_specularmap(SpecularMap* specularmap);
VALUE C_SpecularMap_allocate(VALUE klass);
VALUE C_SpecularMap_initialize(VALUE self, VALUE rb_bitmap);
VALUE C_SpecularMap_get_specular(VALUE self, VALUE rb_point);
inline float get_specular(SpecularMap* specularmap, Point* point);

#endif
