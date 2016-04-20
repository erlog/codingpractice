#ifndef C_BITMAP_H
#define C_BITMAP_H

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
