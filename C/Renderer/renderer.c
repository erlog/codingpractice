//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <float.h>
//Other Libraries
#include <SDL2/SDL.h>
#include <ruby.h>
//Local Includes
#include "renderer.h"
#include "utilities.c"
#include "point.c"
#include "bitmap.c"
#include "wavefront.c"
#include "render.c"
#include "ruby_functions.c"



uint32_t current_time() {
    return SDL_GetTicks();
}

void update_screen(SDL_Renderer* renderer, SDL_Texture* texture, Bitmap* bitmap) {
    SDL_UpdateTexture(texture, 0, bitmap->buffer, bitmap->bytes_per_row);
    SDL_RenderCopyEx(renderer, texture, 0, 0, 0, NULL, SDL_FLIP_VERTICAL);
    SDL_RenderPresent(renderer);
}

int main() {
    //Start Ruby
    ruby_setup_render_environment();

    //Create Backbuffer
    Point* point = allocate_point(100.0, 100.0, 0, 0);
    Color color = pack_color(0, 0, 0, 255);
    color_print(color);
    Bitmap* bitmap = allocate_bitmap(384, 384, color);

    //Initialize Window
    SDL_Window* window = SDL_CreateWindow("Renderer", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, bitmap->width, bitmap->height, SDL_WINDOW_OPENGL);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    //Initialize Backbuffer
    SDL_Texture *screen_texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, bitmap->width,
        bitmap->height);

    SDL_Event event;

    uint32_t last_update = 0;
    uint32_t start_time = current_time();
    uint32_t now;

    VALUE rb_update_func = rb_intern("ruby_update");

    //Setup Renderer
    Point* camera_direction = allocate_point(0.0, 0.0, -1.0, 0.0);
    Point* light_direction = allocate_point(0.0, 0.0, -1.0, 0.0);
    float* view_matrix; float* normal_matrix;
    compute_matrices(20.0, -20.0, -5.0, 5.0, &view_matrix, &normal_matrix);
    ZBuffer* zbuffer = allocate_zbuffer(384, 384);
    VALUE rb_faces; Bitmap* texture; NormalMap* normalmap; SpecularMap* specmap;
    load_model("african_head", &rb_faces, &texture, &normalmap, &specmap);
    //load_model("floor", &rb_faces, &texture, &normalmap, &specmap);
    int drawn_faces = render_model(rb_faces, view_matrix, normal_matrix,
        camera_direction, light_direction, bitmap, zbuffer, texture,
        normalmap, specmap);

    debug_bitmap_output(bitmap);

    while(true) {
        now = current_time();

        if(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                update_screen(renderer, screen_texture, bitmap);
                break;

            case SDL_QUIT:
                ruby_cleanup(0);
                return 0;
                break;
        } }

        //TODO: is there a better way to control our framerate?
        if( (now - last_update) > 32 ) {
            //rb_funcall(rb_cObject, rb_update_func, 0, NULL);

            update_screen(renderer, screen_texture, bitmap);
            last_update = now;
        }
    }
}
