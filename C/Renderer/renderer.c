//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
//Other Libraries
#include <SDL2/SDL.h>
//Local Includes
#include "renderer.h"
#include "utilities.c"
#include "bitmap.c"
#include "point.c"

int main() {
    char timestring[128];
    Color color = pack_color(0, 0, 255, 255);
    Bitmap* bitmap; bitmap = allocate_bitmap(384, 384, color);
    bitmap_write_to_file(bitmap, debug_bitmap_output_string(timestring));

    //Initialize Window
    SDL_Window* window = SDL_CreateWindow("Renderer", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, bitmap->width, bitmap->height, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    //Initialize Backbuffer
    SDL_Texture *texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, bitmap->width,
        bitmap->height);
    SDL_UpdateTexture(texture, 0, bitmap->buffer, bitmap->bytes_per_pixel);
    SDL_RenderCopy(renderer, texture, 0, 0);
    SDL_RenderPresent(renderer);

    while(true) {
        SDL_Event event;
        SDL_WaitEvent(&event);
        if(event.type == SDL_QUIT) { break; }

    }
    return 0;
}
