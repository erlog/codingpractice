//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <float.h>
#include <math.h>
//Other Libraries
#include <SDL.h>
#include <SDL_opengl.h>
#include <ruby.h>
#include "lodepng.c"
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

int main() {
    //Start Ruby
    ruby_setup_render_environment();

    //Initialize Window
    SDL_Init( SDL_INIT_VIDEO ); //TODO: error check(is less than 0?)
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 ); //Use OpenGL 2.1
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
    SDL_Window* window = SDL_CreateWindow( "Renderer", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, 384, 384, SDL_WINDOW_OPENGL);
    SDL_GLContext context = SDL_GL_CreateContext( window );
    SDL_GL_SetSwapInterval( 1 ); //use vsync

    //Initialize OpenGL
    glMatrixMode( GL_PROJECTION ); glLoadIdentity();
    glMatrixMode( GL_MODELVIEW ); glLoadIdentity();
    glClearColor( 0.f, 0.f, 0.f, 1.f );
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glRotatef(180.0,0.0,1.0,0.0);

    SDL_Event event;

    VALUE rb_update_func = rb_intern("ruby_update");

    /*Setup Renderer
    Point* matrix_args = allocate_point(0.0, 0.0, 0.0, 5.0);
    Point* camera_direction = allocate_point(0.0, 0.0, -1.0, 0.0);
    Point* light_direction = allocate_point(0.0, 0.0, -1.0, 0.0);
    float* view_matrix; float* normal_matrix;
    ZBuffer* zbuffer = allocate_zbuffer(384, 384);
    debug_bitmap_output(bitmap);
    */
    Faces faces; Bitmap* old_texture; NormalMap* normalmap; SpecularMap* specmap;
    load_model("african_head", &faces, &old_texture, &normalmap, &specmap);

    //create an OpenGL Texture
    GLuint texture_id = 0;
    uint8_t* pixels;
    uint32_t width;
    uint32_t height;
    char* filename = "objects/african_head/diffuse.png";
    lodepng_decode32_file(&pixels, &width, &height, filename);
    glGenTextures(1, &texture_id);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
         GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );

    uint32_t last_update = 0;
    uint32_t start_time = current_time();
    int frames_drawn = 0;
    uint32_t now;

    while(true) {
        now = current_time();

        while(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                break;

            case SDL_QUIT:
                ruby_cleanup(0);
                float fps = ((float)(now-start_time)/frames_drawn);
                fps = 1000.0/fps;
                printf("%f FPS", fps);
                return 0;
                break;
        } }

        //TODO: is there a better way to control our framerate?
        if( (now - last_update) > 32 ) {
            /*rb_funcall(rb_cObject, rb_update_func, 0, NULL);
            bitmap_clear(bitmap, color);
            zbuffer_clear(zbuffer);
            compute_matrices(matrix_args->x, matrix_args->y, matrix_args->z,
                matrix_args->q, &view_matrix, &normal_matrix);
            render_model(&faces, view_matrix, normal_matrix,
                camera_direction, light_direction, bitmap, zbuffer, texture,
                normalmap, specmap);
            matrix_args->y = (((now-start_time)%20000)/20000.0)*360.0;
            */
            //draw stuff
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glRotatef(0.2f,0.0f,1.0f,0.0f);
            glColor3f(1.0f,1.0f,1.0f);

            glBegin( GL_TRIANGLES );
            int face_i;
            Point* v;
            Point* uv;
            Face* face;
            for(face_i = 0; face_i < faces.length; face_i++) {
                face = &faces.array[face_i];
                v = face->a->v; uv = face->a->uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
                v = face->b->v; uv = face->b->uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
                v = face->c->v; uv = face->c->uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
            }
            glEnd();
            SDL_GL_SwapWindow(window);
            last_update = now;
            frames_drawn++;
        }
    }
}
