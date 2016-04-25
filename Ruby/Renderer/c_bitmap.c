#include "ruby.h"
#include "stdbool.h"
#include "float.h"

#include "c_optimization_main.h"
#include "c_point.h"
#include "c_bitmap.h"

inline void clamp_int(int* value, int min, int max) {
    if(*value < min) { *value = min; }
    if(*value > max) { *value = max; }
    return;
}


VALUE color_multiply(VALUE self, VALUE rb_color_int, VALUE rb_factor) {
    int color = NUM2INT(rb_color_int);
    double factor = NUM2DBL(rb_factor);
    int b = color & 255; color >>= 8;
    int g = color & 255; color >>= 8;
    int r = color & 255; color = 0xFFFFFFFF;
    r *= factor; g *= factor; b *= factor;
    clamp_int(&r, 0, 255); clamp_int(&g, 0, 255); clamp_int(&b, 0, 255);
    int32_t output = 0; r <<= 16; g <<= 8;
    output += (int32_t)r; output += (int32_t)g; output += (int32_t)b;
    return INT2NUM((int)output);
}

inline int32_t rb_color_to_bgr(VALUE rb_color) {
    int r = NUM2INT(rb_ary_entry(rb_color, 0));
    int g = NUM2INT(rb_ary_entry(rb_color, 1));
    int b = NUM2INT(rb_ary_entry(rb_color, 2));
    clamp_int(&r, 0, 255); clamp_int(&g, 0, 255); clamp_int(&b, 0, 255);
    int32_t output = 0;
    r <<= 16; g <<= 8;
    output += (int32_t)r; output += (int32_t)g; output += (int32_t)b;
    return output;
}

inline VALUE bgr_to_rb_color(int32_t bgr) {
    int b = bgr & 0xFF; bgr >>= 8;
    int g = bgr & 0xFF; bgr >>= 8;
    int r = bgr & 0xFF;
    return rb_ary_new3(3, INT2NUM(r), INT2NUM(g), INT2NUM(b));
}

void deallocate_bitmap(Bitmap* bitmap) {
    free(bitmap->buffer);
    xfree(bitmap);
    return;
}

VALUE C_Bitmap_allocate(VALUE klass) {
    Bitmap* bitmap; bitmap = ALLOC(Bitmap);
    return Data_Wrap_Struct(klass, NULL, deallocate_bitmap, bitmap);
}

VALUE C_Bitmap_initialize(VALUE self, VALUE rb_width, VALUE rb_height, VALUE rb_color) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    int width = NUM2INT(rb_width); int height = NUM2INT(rb_height);
    int32_t* buffer; buffer = malloc(sizeof(int32_t)*width*height);
    bitmap->width = width; bitmap->height = height; bitmap->buffer = buffer;

    int32_t color = rb_color_to_bgr(rb_color);
    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*height + x] = color;
    } }

    return self;
}

VALUE C_Bitmap_write_to_file(VALUE self, VALUE rb_path) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    int width = bitmap->width; int height = bitmap->height;
    int bits_per_pixel = 24; int bytes_per_pixel = bits_per_pixel/8;

    FILE* output = fopen(StringValueCStr(rb_path), "wb");

    //Header
    int32_t header[3];
    int size = sizeof(int32_t);
    header[1] = (int32_t)0; header[2] = (int32_t)54; //header size
    header[0] = (int32_t)(width * height * bytes_per_pixel) + header[2];
    fputs("BM", output);
    fwrite(&header, size, 3, output);

    //DIB Header
    int32_t bytes;
    //DIB header size
    bytes = (int32_t)40; fwrite(&bytes, size, 1, output);
    //width
    bytes = (int32_t)bitmap->width; fwrite(&bytes, size, 1, output);
    //height
    bytes = (int32_t)bitmap->height; fwrite(&bytes, size, 1, output);
    //filler
    fputc(1, output); fputc(0, output);
    //bits per pixel
    bytes = (int32_t)bits_per_pixel; fwrite(&bytes, size, 1, output);
    //filler
    fputc(0, output); fputc(0, output);
    //number of pixel bytes
    bytes = header[0] - header[2]; fwrite(&bytes, size, 1, output);
    //constants
    bytes = (int32_t)2835;
    fwrite(&bytes, size, 1, output); fwrite(&bytes, size, 1, output);
    //filler
    bytes = (int32_t)0;
    fwrite(&bytes, size, 1, output); fwrite(&bytes, size, 1, output);

    //write pixels
    int y; int x; int i; int32_t color;
    int padlength = (4 - ((width * bytes_per_pixel) % 4)) % 4;
    for(y=0; y<height; y++) {
        for(x=0; x<width; x++) {
            color = bitmap->buffer[y*width + x];
            fputc(color & 255, output); color >>= 8;
            fputc(color & 255, output); color >>= 8;
            fputc(color & 255, output);
        }
        for(i=0; i<padlength; i++) {
            fputc(0, output);
        }
    }
    return Qnil;
}

VALUE C_Bitmap_set_pixel(VALUE self, VALUE rb_point, VALUE rb_color) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    Point* point; Data_Get_Struct(rb_point, Point, point);
    int32_t color = (int32_t)NUM2INT(rb_color);
    bitmap->buffer[(int)point->y*bitmap->width + (int)point->x] = color;
    return self;
}
VALUE C_Bitmap_get_pixel(VALUE self, VALUE rb_point) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    Point* point; Data_Get_Struct(rb_point, Point, point);
    int32_t color = bitmap->buffer[(int)point->y*bitmap->width + (int)point->x];
    return INT2NUM((int)color);
}

VALUE C_Bitmap_dimensions(VALUE self) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    return rb_ary_new3(2, INT2NUM(bitmap->width), INT2NUM(bitmap->height));
}
VALUE C_Bitmap_width(VALUE self) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    return INT2NUM(bitmap->width);
}
VALUE C_Bitmap_height(VALUE self) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    return INT2NUM(bitmap->height);
}


void deallocate_zbuffer(ZBuffer* zbuffer) {
    free(zbuffer->buffer);
    xfree(zbuffer);
    return;
}

VALUE C_ZBuffer_allocate(VALUE klass) {
    ZBuffer* zbuffer; zbuffer = ALLOC(ZBuffer);
    return Data_Wrap_Struct(klass, NULL, deallocate_zbuffer, zbuffer);
}

VALUE C_ZBuffer_initialize(VALUE self, VALUE rb_width, VALUE rb_height) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    int width = NUM2INT(rb_width); int height = NUM2INT(rb_height);
    double* buffer; buffer = malloc(sizeof(double)*width*height);
    zbuffer->width = width; zbuffer->height = height; zbuffer->buffer = buffer;
    zbuffer->drawn_pixels = 0; zbuffer->oob_pixels = 0; zbuffer->occluded_pixels = 0;

    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*width + x] = -DBL_MAX;
        } }

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

    double value = zbuffer->buffer[(int)point->y*zbuffer->width + (int)point->x];
    if(point->z > value) {
        zbuffer->buffer[(int)point->y*zbuffer->width + (int)point->x] = point->z;
        zbuffer->drawn_pixels += 1;
        return Qtrue;
    }

    zbuffer->occluded_pixels += 1;
    return Qfalse;
}
