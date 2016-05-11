//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <float.h>
#include <math.h>
//Other Libraries
#include <GL/glew.h>
#include <SDL.h>
#include <SDL_opengl.h>
#include <ruby.h>
#include "lodepng.c"
//Globals
char* AssetFolderPath = "objects";
char* OutputFolderPath = "output";
bool IsRunning = true;
uint32_t StartTime = 0;
uint32_t CurrentTime = 0;
uint32_t LastUpdateTime = 0;
uint32_t DeltaTime = 1000; //so we don't miss rendering the first frame
//Local Includes
#include "renderer.h"
#include "wavefront.c"
#include "utilities.c"
//#include "ruby_functions.c"

uint32_t current_time() {
    return SDL_GetTicks();
}

int main() {
    //INITIALIZATION- Failures here cause a hard exit

    //Initialize screen struct and buffer for taking screenshots
    Texture screen; screen.asset_path = "SCREEN";
    screen.width = 384; screen.height = 384; screen.bytes_per_pixel = 3;
    screen.pitch = screen.width * screen.bytes_per_pixel;
    screen.buffer_size = screen.pitch * screen.height;
    screen.buffer = malloc(screen.buffer_size);

    //Start Ruby
    //ruby_setup_render_environment();
    //VALUE rb_update_func = rb_intern("ruby_update");

    //Initialize SDL and OpenGL
    SDL_Event event;
    if(SDL_Init(SDL_INIT_VIDEO) != 0) {
        //TODO: spit out actual SDL error code
        message_log("Couldn't initialize-","SDL"); return 0;
    }
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 ); //Use OpenGL 2.1
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
    SDL_Window* window = SDL_CreateWindow( "Renderer", SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, screen.width, screen.height, SDL_WINDOW_OPENGL);
    if(window == NULL) {
        message_log("Couldn't initialize-", "SDL OpenGL window"); return 0;
    }
    SDL_GLContext context = SDL_GL_CreateContext( window );
    if(context == NULL) {
        message_log("Couldn't get-", "OpenGL Context for window"); return 0;
    }
    SDL_GL_SetSwapInterval( 1 ); //use vsync
    if(glewInit() != GLEW_OK) {
        message_log("Couldn't initialize-", "GLEW"); return 0;
    }
    if(!GLEW_VERSION_2_1) {
        message_log("OpenGL 2.1 not supported by GLEW", ""); return 0;
    }

    //Set up simple OpenGL environment for rendering
    glMatrixMode( GL_PROJECTION ); glLoadIdentity();
    glMatrixMode( GL_MODELVIEW ); glLoadIdentity();
    glClearColor( 0.f, 0.f, 0.f, 1.f );
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glRotatef(180.0,0.0,1.0,0.0);


    //Intialize Shaders

    //GAME INIT- Failures here may cause a proper smooth exit when necessary
    Object object; object.object_name = "african_head";
    if(!load_object(&object)) { IsRunning = false; };

    StartTime = current_time();
    int frames_drawn = 0;

    //MAIN LOOP- Failures here may cause a proper smooth exit when necessary
    message_log("Starting update loop.", "");
    while(IsRunning) {
        CurrentTime = current_time();
        DeltaTime = CurrentTime - LastUpdateTime;

        while(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                break;

            case SDL_QUIT:
                IsRunning = false;
                break;
        } }

        //TODO: is there a better way to control our framerate?
        if( DeltaTime > 32 ) {
            //rb_funcall(rb_cObject, rb_update_func, 0, NULL);
            glRotatef(0.2f,0.0f,1.0f,0.0f);
            //draw stuff
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glUseProgram(object.shader_program);
            GLint uniform_location = glGetUniformLocation(object.shader_program,
                "diffuse");
            glUniform1i(uniform_location, GL_TEXTURE0);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, object.texture->texture_id);
            glBegin( GL_TRIANGLES );
            int face_i;
            for(face_i = 0; face_i < object.model->face_count; face_i++) {
                Face* face = &object.model->faces[face_i];
                Point* v; Point* uv;
                v = &face->a.v; uv = &face->a.uv;
                glTexCoord2f(uv->x, uv->y); glVertex3f( v->x, v->y, v->z );
                v = &face->b.v; uv = &face->b.uv;
                glTexCoord2f(uv->x, uv->y); glVertex3f( v->x, v->y, v->z );
                v = &face->c.v; uv = &face->c.uv;
                glTexCoord2f(uv->x, uv->y); glVertex3f( v->x, v->y, v->z );
            }
            glEnd();
            SDL_GL_SwapWindow(window);
            LastUpdateTime = CurrentTime;
            frames_drawn++;
        }
    }

    take_screenshot(&screen);
    float fps = 1000.0/((float)(CurrentTime-StartTime)/frames_drawn);
    printf("%f FPS", fps); //TODO:use message log for this
    //ruby_cleanup(0);
    SDL_Quit();
    return 0;
}
