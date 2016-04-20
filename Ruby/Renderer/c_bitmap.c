#include "ruby.h"
#include "stdbool.h"
#include "float.h"

#include "c_optimization_main.h"
#include "c_point.h"
#include "c_bitmap.h"

void deallocate_zbuffer(ZBuffer* zbuffer) {
    free(zbuffer->buffer);
    xfree(zbuffer);
    return;
}

VALUE C_ZBuffer_allocate(VALUE klass) {
    ZBuffer* zbuffer; zbuffer = ALLOC(ZBuffer);
    //TODO: this is going to leak the memory of the actual buffer
    return Data_Wrap_Struct(klass, NULL, deallocate_zbuffer, zbuffer);
}

VALUE C_ZBuffer_initialize(VALUE self, VALUE rb_width, VALUE rb_height) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    int width = NUM2INT(rb_width); int height = NUM2INT(rb_height);

    double* buffer; buffer = malloc(sizeof(double)*width*height);

    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*height + x] = -DBL_MAX;
        } }

    zbuffer->width = width; zbuffer->height = height; zbuffer->buffer = buffer;
    zbuffer->drawn_pixels = 0; zbuffer->oob_pixels = 0; zbuffer->occluded_pixels = 0;
    return self;
}

VALUE C_ZBuffer_drawn_pixels(VALUE self) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    return INT2NUM(zbuffer->drawn_pixels);
}
VALUE C_ZBuffer_oob_pixels(VALUE self) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    return INT2NUM(zbuffer->oob_pixels);
}
VALUE C_ZBuffer_occluded_pixels(VALUE self) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    return INT2NUM(zbuffer->occluded_pixels);
}

VALUE C_ZBuffer_should_draw(VALUE self, VALUE rb_point) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    Point* point; Data_Get_Struct(rb_point, Point, point);

    if( (point->x < 0) || (point->x >= zbuffer->width) ||
        (point->y < 0) || (point->y >= zbuffer->height) ) {
        zbuffer->oob_pixels += 1;
        return Qfalse; }

    double value = zbuffer->buffer[(int)point->y*zbuffer->height + (int)point->x];
    if(point->z > value) {
        zbuffer->buffer[(int)point->y*zbuffer->height + (int)point->x] = point->z;
        zbuffer->drawn_pixels += 1;
        return Qtrue;
    }

    zbuffer->occluded_pixels += 1;
    return Qfalse;
}
