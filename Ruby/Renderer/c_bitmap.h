#ifndef C_BITMAP_H
#define C_BITMAP_H

//generic functions
VALUE color_multiply(VALUE self, VALUE rb_color_int, VALUE rb_factor);

//Bitmap class
typedef struct c_bitmap { int width; int height; int32_t* buffer; } Bitmap;
void C_Bitmap_deallocate(void* my_struct);
VALUE C_Bitmap_allocate(VALUE klass);
VALUE C_Bitmap_initialize(VALUE self, VALUE rb_width, VALUE rb_height, VALUE rb_color);
VALUE C_Bitmap_set_pixel(VALUE self, VALUE rb_point, VALUE rb_color);
VALUE C_Bitmap_get_pixel(VALUE self, VALUE rb_point);
VALUE C_Bitmap_write_to_file(VALUE self, VALUE rb_path);
VALUE C_Bitmap_dimensions(VALUE self);
VALUE C_Bitmap_width(VALUE self);
VALUE C_Bitmap_height(VALUE self);

//ZBuffer class with some stuff included for debug purposes
typedef struct c_zbuffer { int width; int height; double* buffer;
                           int drawn_pixels; int oob_pixels;
                           int occluded_pixels; } ZBuffer;

void C_ZBuffer_deallocate(void* my_struct);
VALUE C_ZBuffer_allocate(VALUE klass);
VALUE C_ZBuffer_initialize(VALUE self, VALUE rb_width, VALUE rb_height);
VALUE C_ZBuffer_set_point(VALUE self, VALUE rb_point);
VALUE C_ZBuffer_get_point(VALUE self, VALUE rb_point);
VALUE C_ZBuffer_drawn_pixels(VALUE self);
VALUE C_ZBuffer_oob_pixels(VALUE self);
VALUE C_ZBuffer_occluded_pixels(VALUE self);
VALUE C_ZBuffer_should_draw(VALUE self, VALUE rb_point);

#endif
