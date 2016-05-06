//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
//Other Libraries
#include <SDL2/SDL.h>
#include <ruby.h>
//Local Includes
#include "renderer.h"
#include "utilities.c"
#include "point.c"
#include "bitmap.c"

void update_screen(SDL_Renderer* renderer, SDL_Texture* texture, Bitmap* bitmap) {
    SDL_UpdateTexture(texture, 0, bitmap->buffer, bitmap->bytes_per_row);
    SDL_RenderCopy(renderer, texture, 0, 0);
    SDL_RenderPresent(renderer);
}

int main() {
    char timestring[128];
    Color color = pack_color(255, 255, 255, 255);
    Point* point = allocate_point(100.0, 100.0, 0, 0);
    Bitmap* bitmap = allocate_bitmap(384, 384, color);
    color = pack_color(0,0,0,255);
    //bitmap_write_to_file(bitmap, debug_bitmap_output_string(timestring));

    //Initialize Ruby
    ruby_init();
    ruby_init_loadpath();

    VALUE thing = DBL2NUM(2.0);
    //Initialize Window
    SDL_Window* window = SDL_CreateWindow("Renderer", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, bitmap->width, bitmap->height, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    //Initialize Backbuffer
    SDL_Texture *texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, bitmap->width,
        bitmap->height);

    SDL_Event event;

    uint32_t last_update = 0;
    uint32_t start_time = SDL_GetTicks();
    uint32_t current_time;
    point->x = 0.0; point->y = 0.0;
    while(true) {
        current_time = SDL_GetTicks();
        if(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                update_screen(renderer, texture, bitmap);
                break;

            case SDL_QUIT:
                ruby_cleanup(0);
                return 0;
                break;
        } }
        //if( ((current_time - last_update) > 32) &
        if( (point->x < bitmap->width) & (point->y < bitmap->height) ) {
            bitmap_set_pixel(bitmap, point, color);
            point->x += 1.0; point->y += 1.0;
            update_screen(renderer, texture, bitmap);
            last_update = current_time;
        }
        if(point->x > bitmap->height-1) {
            printf("FPS: %f\n", 1000/((SDL_GetTicks() - start_time)/384.0));
            return 0;
        }
    }
}
