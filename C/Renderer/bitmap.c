//Color Functions
inline void clamp_channel(uint8_t* value, uint8_t min, uint8_t max) {
    if(*value < min) { *value = min; }
    if(*value > max) { *value = max; }
    return;
}

inline Color color_multiply(Color color, double factor) {
    color.rgba.r *= factor; color.rgba.g *= factor; color.rgba.b *= factor;
    clamp_channel(&color.rgba.r, 0, 255);
    clamp_channel(&color.rgba.g, 0, 255);
    clamp_channel(&color.rgba.b, 0, 255);
    return color;
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

Bitmap* allocate_bitmap(int width, int height, Color color) {
    Bitmap* bitmap; bitmap = malloc(sizeof(Bitmap));
    Color* buffer; buffer = malloc(sizeof(Color)*width*height);
    bitmap->width = width; bitmap->height = height; bitmap->buffer = buffer;
    bitmap->bytes_per_pixel = sizeof(uint32_t);
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

