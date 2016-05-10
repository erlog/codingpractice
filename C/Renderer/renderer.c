//Globals
char* AssetFolderPath = "objects";

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
#include "wavefront.c"
#include "utilities.c"
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

    //Load objects
    Object object; object.object_name = "african_head"; load_object(&object);

    SDL_Event event;

    VALUE rb_update_func = rb_intern("ruby_update");

    uint32_t last_update = 0;
    uint32_t start_time = current_time();
    int frames_drawn = 0;
    uint32_t now;

    GLubyte* screenshot = malloc(sizeof(GLubyte)*3*384*384);

    while(true) {
        now = current_time();

        while(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                break;

            case SDL_QUIT:
                glReadPixels(0, 0, 384, 384, GL_RGB, GL_UNSIGNED_BYTE, screenshot);
                lodepng_encode24_file("test.png", (const unsigned char*)screenshot, 384, 384);
                float fps = ((float)(now-start_time)/frames_drawn);
                fps = 1000.0/fps;
                printf("%f FPS", fps);
                return 0;
                break;
        } }

        //TODO: is there a better way to control our framerate?
        if( (now - last_update) > 32 ) {
            //rb_funcall(rb_cObject, rb_update_func, 0, NULL);

            //draw stuff
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glRotatef(0.2f,0.0f,1.0f,0.0f);
            //glColor3f(1.0f,1.0f,1.0f);
            glBindTexture(GL_TEXTURE_2D, object.texture->texture_id);
            glBegin( GL_TRIANGLES );
            int face_i;
            for(face_i = 0; face_i < object.model->face_count; face_i++) {
                Face* face = &object.model->faces[face_i];
                Point* v; Point* uv;
                v = &face->a.v; uv = &face->a.uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
                v = &face->b.v; uv = &face->b.uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
                v = &face->c.v; uv = &face->c.uv;
                glTexCoord2f(uv->x, 1.0 - uv->y); glVertex3f( v->x, v->y, v->z );
            }
            glEnd();
            SDL_GL_SwapWindow(window);
            last_update = now;
            frames_drawn++;
        }
    }

}
