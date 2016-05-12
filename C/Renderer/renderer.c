//C Standard Library
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <float.h>
#include <math.h>
//Other Libraries
#include <GL/glew.h>
#include <GL/glext.h>
#include <SDL.h>
#include <SDL_opengl.h>
#include <ruby.h>
#include "lodepng.c"

//State Struct
typedef struct c_state {
    char* AssetFolderPath;
    char* OutputFolderPath;
    bool IsRunning;
    uint32_t StartTime;
    uint32_t CurrentTime;
    uint32_t LastUpdateTime;
    uint32_t DeltaTime;
} State_Struct;
State_Struct State;
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
    State.AssetFolderPath = "objects";
    State.OutputFolderPath = "output";
    State.IsRunning = true;
    State.StartTime = 0;
    State.CurrentTime = 0;
    State.LastUpdateTime = 0;
    State.DeltaTime = 0;

    //Initialize screen struct and buffer for taking screenshots
    Texture screen; screen.asset_path = "Flamerokz";
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

    SDL_Window* window = SDL_CreateWindow( screen.asset_path, SDL_WINDOWPOS_CENTERED,
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
    glEnable(GL_CULL_FACE);
    glDepthRange(1.0, 0.0); //change the handedness of the z axis
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    //Intialize Shaders

    //GAME INIT- Failures here may cause a proper smooth exit when necessary
    Object object; object.object_name = "african_head";
    if(!load_object(&object)) { State.IsRunning = false; };

    State.StartTime = current_time();
    int frames_drawn = 0;

    //MAIN LOOP- Failures here may cause a proper smooth exit when necessary
    message_log("Starting update loop.", "");
    while(State.IsRunning) {
        State.CurrentTime = current_time();
        State.DeltaTime = State.CurrentTime - State.LastUpdateTime;

        while(SDL_PollEvent(&event)) { switch(event.type) {
            case SDL_WINDOWEVENT:
                break;

            case SDL_KEYDOWN:
                if(event.key.keysym.sym == SDLK_ESCAPE) { State.IsRunning = false; }
                break;

            case SDL_QUIT:
                State.IsRunning = false;
                break;
        } }

        //TODO: is there a better way to control our framerate?
        if( State.DeltaTime > 32 ) {
            //rb_funcall(rb_cObject, rb_update_func, 0, NULL);
            glRotatef(0.2f,0.0f,-1.0f,0.0f);
            //draw stuff
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glUseProgram(object.shader_program);

            //Bind diffuse texture
            GLint uniform_location = glGetUniformLocation(object.shader_program,
                "diffuse");
            glUniform1i(uniform_location, 0);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, object.texture->id);

            //Bind normal map
            uniform_location = glGetUniformLocation(object.shader_program,
                "normal");
            glUniform1i(uniform_location, 1);
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, object.normal_map->id);

            //Bind specular map
            uniform_location = glGetUniformLocation(object.shader_program,
                "specular");
            glUniform1i(uniform_location, 2);
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, object.specular_map->id);

            //Bind Attributes
            GLint normal_location = glGetAttribLocation(object.shader_program,
                "surface_normal");
            GLint tangent_location = glGetAttribLocation(object.shader_program,
                "surface_tangent");


            glBegin( GL_TRIANGLES );
            int face_i; Face* face; Point* v; Point* uv; Point* n; Point* t;
            for(face_i = 0; face_i < object.model->face_count; face_i++) {
                face = &object.model->faces[face_i];
                v = &face->a.v; uv = &face->a.uv; n = &face->a.n; t = &face->a.t;
                glTexCoord2f( uv->x, uv->y );
                glVertexAttrib3f(normal_location, n->x, n->y, n->z);
                glVertexAttrib3f(tangent_location, t->x, t->y, t->z);
                glVertex3f( v->x, v->y, v->z );
                v = &face->b.v; uv = &face->b.uv; n = &face->b.n; t = &face->a.t;
                glTexCoord2f( uv->x, uv->y );
                glVertexAttrib3f(normal_location, n->x, n->y, n->z);
                glVertexAttrib3f(tangent_location, t->x, t->y, t->z);
                glVertex3f( v->x, v->y, v->z );
                v = &face->c.v; uv = &face->c.uv; n = &face->c.n; t = &face->a.t;
                glTexCoord2f( uv->x, uv->y );
                glVertexAttrib3f(normal_location, n->x, n->y, n->z);
                glVertexAttrib3f(tangent_location, t->x, t->y, t->z);
                glVertex3f( v->x, v->y, v->z );
            }
            glEnd();
            SDL_GL_SwapWindow(window);
            State.LastUpdateTime = State.CurrentTime;
            frames_drawn++;
        }
    }

    take_screenshot(&screen);
    float fps = 1000.0/((float)(State.CurrentTime-State.StartTime)/frames_drawn);
    printf("%f FPS", fps); //TODO:use message log for this
    //ruby_cleanup(0);
    SDL_Quit();
    return 0;
}
