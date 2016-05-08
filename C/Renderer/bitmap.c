//Color Functions
void clamp_channel(uint8_t* value, uint8_t min, uint8_t max) {
    if(*value < min) { *value = min; }
    if(*value > max) { *value = max; }
    return;
}

Color color_multiply(Color color, float factor) {
    color.rgba.r *= factor; color.rgba.g *= factor; color.rgba.b *= factor;
    clamp_channel(&color.rgba.r, 0, 255);
    clamp_channel(&color.rgba.g, 0, 255);
    clamp_channel(&color.rgba.b, 0, 255);
    return color;
}

void color_print(Color color) {
    printf("Color: (r-%i, g-%i, b-%i, a-%i)\n",
        color.rgba.r, color.rgba.g, color.rgba.b, color.rgba.a);
    return;
}

Color pack_color(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    Color clr; clr.rgba.r = r; clr.rgba.g = g; clr.rgba.b = b; clr.rgba.a = a;
    return clr;
}

//Bitmap Functions
void deallocate_bitmap(Bitmap* bitmap) {
    //TODO: this doesn't free properly
    free(bitmap->buffer); free(bitmap); return;
}

VALUE C_Bitmap_allocate(VALUE klass) {
    Bitmap* bitmap; bitmap = ALLOC(Bitmap);
    return Data_Wrap_Struct(klass, NULL, deallocate_bitmap, bitmap);
}

VALUE C_Bitmap_initialize(VALUE self, VALUE rb_width, VALUE rb_height, VALUE rb_color) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    int width = NUM2INT(rb_width); int height = NUM2INT(rb_height);
    Color color; color.bytes = (uint32_t)NUM2INT(rb_color);

    Color* buffer; buffer = malloc(sizeof(Color)*width*height);
    bitmap->width = width; bitmap->height = height; bitmap->buffer = buffer;
    bitmap->bytes_per_pixel = sizeof(Color);
    bitmap->bytes_per_row = bitmap->width * bitmap->bytes_per_pixel;

    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*width + x] = color;
    } }

    return self;
}

Bitmap* allocate_bitmap(int width, int height, Color color) {
    Bitmap* bitmap; bitmap = ALLOC(Bitmap);
    Color* buffer; buffer = malloc(sizeof(Color)*width*height);
    bitmap->width = width; bitmap->height = height; bitmap->buffer = buffer;
    bitmap->bytes_per_pixel = sizeof(Color);
    bitmap->bytes_per_row = bitmap->width * bitmap->bytes_per_pixel;
    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*width + x] = color;
    } }
    return bitmap;
}

Color bitmap_get_pixel(Bitmap* bitmap, Point* point) {
    return bitmap->buffer[(int)point->y*bitmap->width + (int)point->x];
}

void bitmap_set_pixel(Bitmap* bitmap, Point* point, Color color) {
    bitmap->buffer[(int)point->y*bitmap->width + (int)point->x] = color;
    return;
}

VALUE C_Bitmap_set_pixel(VALUE self, VALUE rb_point, VALUE rb_color) {
    Bitmap* bitmap; Data_Get_Struct(self, Bitmap, bitmap);
    Point* point; Data_Get_Struct(rb_point, Point, point);
    Color color; color.bytes = (uint32_t)NUM2UINT(rb_color);
    bitmap_set_pixel(bitmap, point, color);
    return self;
}

void bitmap_write_to_file(Bitmap* bitmap, char* path) {
    int width = bitmap->width; int height = bitmap->height;
    int bits_per_pixel = 24; int bytes_per_pixel = bits_per_pixel/8;

    FILE* output = fopen(path, "wb");

    //Header
    uint32_t header[3];
    int size = sizeof(uint32_t);
    header[1] = (uint32_t)0; header[2] = (uint32_t)54; //header size
    header[0] = (uint32_t)(width * height * bytes_per_pixel) + header[2];
    fputs("BM", output);
    fwrite(&header, size, 3, output);

    //DIB Header
    uint32_t bytes;
    //DIB header size
    bytes = (uint32_t)40; fwrite(&bytes, size, 1, output);
    //width
    bytes = (uint32_t)bitmap->width; fwrite(&bytes, size, 1, output);
    //height
    bytes = (uint32_t)bitmap->height; fwrite(&bytes, size, 1, output);
    //filler
    fputc(1, output); fputc(0, output);
    //bits per pixel
    bytes = (uint32_t)bits_per_pixel; fwrite(&bytes, size, 1, output);
    //filler
    fputc(0, output); fputc(0, output);
    //number of pixel bytes
    bytes = header[0] - header[2]; fwrite(&bytes, size, 1, output);
    //constants
    bytes = (uint32_t)2835;
    fwrite(&bytes, size, 1, output); fwrite(&bytes, size, 1, output);
    //filler
    bytes = (uint32_t)0;
    fwrite(&bytes, size, 1, output); fwrite(&bytes, size, 1, output);

    //write pixels
    int y; int x; int i; Color color;
    int padlength = (4 - ((width * bytes_per_pixel) % 4)) % 4;
    for(y=0; y<height; y++) {
        //write first 3 bytes of pixel data(rgb minus alpha)
        for(x=0; x<width; x++) {
            color = bitmap->buffer[y*width + x];
            fwrite(&color, 3, 1, output);
        }
        //write padding
        for(i=0; i<padlength; i++) {
            fputc(0, output);
        }
    }
    return;
}

void debug_bitmap_output(Bitmap* bitmap) {
    char string[256];
    time_t now; struct tm* timeinfo;
    time(&now); timeinfo = localtime(&now);
    strftime(&string[0], 79, "output/renderer - %Y-%m-%d %H:%M:%S.bmp",timeinfo);
    bitmap_write_to_file(bitmap, string);
    return;
}

//C_ZBuffer
void deallocate_zbuffer(ZBuffer* zbuffer) {
    free(zbuffer->buffer); xfree(zbuffer); return;
}

VALUE C_ZBuffer_allocate(VALUE klass) {
    ZBuffer* zbuffer; zbuffer = ALLOC(ZBuffer);
    return Data_Wrap_Struct(klass, NULL, deallocate_zbuffer, zbuffer);
}

VALUE C_ZBuffer_initialize(VALUE self, VALUE rb_width, VALUE rb_height) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    int width = NUM2INT(rb_width); int height = NUM2INT(rb_height);
    float* buffer; buffer = malloc(sizeof(float)*width*height);
    zbuffer->width = width; zbuffer->height = height; zbuffer->buffer = buffer;
    zbuffer->drawn_pixels = 0; zbuffer->oob_pixels = 0; zbuffer->occluded_pixels = 0;

    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*width + x] = -DBL_MAX;
        } }

    return self;
}

ZBuffer* allocate_zbuffer(int width, int height) {
    ZBuffer* zbuffer; zbuffer = ALLOC(ZBuffer);

    float* buffer; buffer = malloc(sizeof(float)*width*height);
    zbuffer->width = width; zbuffer->height = height; zbuffer->buffer = buffer;
    zbuffer->drawn_pixels = 0; zbuffer->oob_pixels = 0; zbuffer->occluded_pixels = 0;

    int x; int y;
    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            buffer[y*width + x] = -DBL_MAX;
        } }

    return zbuffer;
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

bool zbuffer_should_draw(ZBuffer* zbuffer, Point* point) {
    if( (point->x < 0) || (point->x >= zbuffer->width) ||
        (point->y < 0) || (point->y >= zbuffer->height) ) {
        zbuffer->oob_pixels += 1;
        return false; }

    float value = zbuffer->buffer[(int)point->y*zbuffer->width + (int)point->x];
    if(point->z > value) {
        zbuffer->buffer[(int)point->y*zbuffer->width + (int)point->x] = point->z;
        zbuffer->drawn_pixels += 1;
        return true;
    }

    zbuffer->occluded_pixels += 1;
    return false;
}

VALUE C_ZBuffer_should_draw(VALUE self, VALUE rb_point) {
    ZBuffer* zbuffer; Data_Get_Struct(self, ZBuffer, zbuffer);
    Point* point; Data_Get_Struct(rb_point, Point, point);
    if(zbuffer_should_draw(zbuffer, point)) { return Qtrue; }
    return Qfalse;
}

//C_TangentSpaceNormalMap
void deallocate_normalmap(NormalMap* normalmap) {
    free(normalmap->buffer); xfree(normalmap); return;
}

VALUE C_NormalMap_allocate(VALUE klass) {
    NormalMap* normalmap; normalmap = ALLOC(NormalMap);
    return Data_Wrap_Struct(klass, NULL, deallocate_normalmap, normalmap);
}

VALUE C_NormalMap_initialize(VALUE self, VALUE rb_bitmap) {
    NormalMap* normalmap; Data_Get_Struct(self, NormalMap, normalmap);
    Bitmap* bitmap; Data_Get_Struct(rb_bitmap, Bitmap, bitmap);
    int width = bitmap->width; int height = bitmap->height;
    normalmap->width = width; normalmap->height = height;


    Point* buffer; buffer = malloc(sizeof(Point)*width*height);
    normalmap->buffer = buffer;

    int x; int y;
    int index;
    Color color;
    int r; int g; int b;

    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            index = y*width + x;
            color = bitmap->buffer[index];
            Point* normal; normal = ALLOC(Point);
            normal->x = (float)(color.rgba.r/127.5) - 1;
            normal->y = (float)(color.rgba.g/127.5) - 1;
            normal->z = (float)(color.rgba.b/127.5) - 1;
            normalize(normal);
            normalmap->buffer[index] = *normal;
    } }

    return self;
}

Point* get_normal(NormalMap* normalmap, Point* point) {
    return &normalmap->buffer[(int)(point->y*normalmap->width + point->x)];
}

//SpecularMap
void deallocate_specularmap(SpecularMap* specularmap) {
    free(specularmap->buffer); xfree(specularmap); return;
}

VALUE C_SpecularMap_allocate(VALUE klass) {
    SpecularMap* specularmap; specularmap = ALLOC(SpecularMap);
    return Data_Wrap_Struct(klass, NULL, deallocate_specularmap, specularmap);
}

VALUE C_SpecularMap_initialize(VALUE self, VALUE rb_bitmap) {
    SpecularMap* specularmap; Data_Get_Struct(self, SpecularMap, specularmap);
    Bitmap* bitmap; Data_Get_Struct(rb_bitmap, Bitmap, bitmap);
    int width = bitmap->width; int height = bitmap->height;
    specularmap->width = width; specularmap->height = height;


    float* buffer; buffer = malloc(sizeof(float)*width*height);
    specularmap->buffer = buffer;

    int x; int y;
    int index; int b;
    float specularity;

    for(y = 0; y < height; y++) { for(x = 0; x < width; x++) {
            index = y*width + x;
            b = bitmap->buffer[index].rgba.b;
            specularity = clamp_float((float)(1-b/255)*100.0, 1, 24);
            specularmap->buffer[index] = specularity;
    } }

    return self;
}

float get_specular(SpecularMap* specularmap, Point* point) {
    return specularmap->buffer[(int)point->y*specularmap->width + (int)point->x];
}
