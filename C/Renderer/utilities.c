//Small functions that don't fit anywhere else with minimal dependencies
char* construct_asset_path(char* object_name, char* filename) {
    int asset_path_length = strlen(State.AssetFolderPath) + strlen(object_name) +
        strlen(filename) + 3; //1 extra for null terminator + 2 for slashes
    char* asset_path = malloc(sizeof(char)*asset_path_length);
    sprintf(asset_path, "%s/%s/%s", State.AssetFolderPath, object_name, filename);
    return asset_path;
}

char* get_datetime_string() {
    time_t rawtime; struct tm *info;
    char* output = malloc(sizeof(char)*255);

    time( &rawtime ); info = localtime( &rawtime );
    strftime(output, 255,"%Y-%m-%d %H:%M:%S", info); //TODO: 255?
    return output;
}

bool read_entire_file(char* file_path, char** output_string) {
    FILE* file = fopen(file_path, "r");
    if(file == NULL) { return false; }
    fseek(file, 0, SEEK_END);
    int size = ftell(file);
    *output_string = malloc(sizeof(char)*size+1); //+1 for null terminator
    fseek(file, 0, SEEK_SET);
    fread(*output_string, sizeof(char), size, file);
    (*output_string)[size-1] = '\0';
    return true;
}

void message_log(char* message, char* predicate) {
    printf("%.2f: %s %s\n", State.CurrentTime/1000.0, message, predicate);
}

void flip_texture(Texture* texture) {
    uint8_t* buffer = malloc(texture->buffer_size);
    int src_i; int dest_i; int y; int x;
    for(src_i = 0; src_i < texture->buffer_size; src_i++) {
        y = src_i / texture->pitch; x = src_i % texture->pitch;
        dest_i = ((texture->height - y - 1) * texture->pitch) + x;
        buffer[dest_i] = texture->buffer[src_i];
    }
    free(texture->buffer);
    texture->buffer = buffer;
    return;
}

bool load_shader(char* shader_path, GLuint* shader_id, GLenum shader_type) {
    char* shader_source_chars;
    if(!read_entire_file(shader_path, &shader_source_chars)) {
        message_log("Error loading file-", shader_path);
    }
    *shader_id = glCreateShader(shader_type);
    const GLchar* shader_source = shader_source_chars;
    glShaderSource(*shader_id, 1, (const GLchar**)&shader_source, NULL);
    glCompileShader(*shader_id);
    free(shader_source_chars);

    GLint compiled = GL_FALSE;
    glGetShaderiv(*shader_id, GL_COMPILE_STATUS, &compiled);
    if(compiled != GL_TRUE ) {
        message_log("Open GL-", "error compiling shader");
        message_log("Source:", (char*)shader_source);
        GLchar buffer[1024];
        glGetShaderInfoLog(*shader_id, 1024, NULL, buffer);
        message_log("Open GL-", buffer);
        return false;
    }
    return true;
}


bool load_texture(char* object_name, char* filename, Texture* texture) {
    texture->asset_path = construct_asset_path(object_name, filename);

    //Load PNG
    unsigned width; unsigned height;
    if(lodepng_decode32_file(&texture->buffer, &width, &height,
        texture->asset_path)) { return false; }

    //Create texture struct
    texture->bytes_per_pixel = 4;
    texture->width = (GLsizei)width; texture->height = (GLsizei)height;
    texture->pitch = texture->bytes_per_pixel * texture->width;
    texture->buffer_size = texture->pitch * texture->height;

    //Flip it because OpenGL coords start in the lower left
    flip_texture(texture);

    //Register our texture with OpenGL
    //TODO: error handling
    glGenTextures(1, &texture->id);
    glBindTexture(GL_TEXTURE_2D, texture->id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture->width, texture->height, 0,
         GL_RGBA, GL_UNSIGNED_BYTE, texture->buffer);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 4.0f);
    glBindTexture(GL_TEXTURE_2D, 0); //unbind the texture
    return true;
}

bool load_object(Object* object) {
    //Texture
    object->texture = malloc(sizeof(Texture));
    if(!load_texture(object->object_name, "diffuse.png", object->texture)) {
        message_log("Error loading texture-", object->object_name);
        return false;
    }
    //Normal Map
    object->normal_map= malloc(sizeof(Texture));
    if(!load_texture(object->object_name, "nm_tangent.png", object->normal_map)) {
        message_log("Error loading normal map-", object->object_name);
        return false;
    }
    //Specular Map
    object->specular_map = malloc(sizeof(Texture));
    if(!load_texture(object->object_name, "spec.png", object->specular_map)) {
        message_log("Error loading specular map-", object->object_name);
        return false;
    }
    //Model
    object->model = malloc(sizeof(Model));
    if(!load_model(object->object_name, object->model)) {
        message_log("Error loading model-", object->object_name);
        return false;
    }
    //Shaders
    char* path;
    object->shader_program = glCreateProgram();
    path = construct_asset_path(object->object_name, "vertex.shader");
    GLuint shader_id;
    if(!load_shader(path, &shader_id, GL_VERTEX_SHADER)) {
        message_log("Error loading vertex shader-", object->object_name);
        free(path);
        return false;
    }
    glAttachShader(object->shader_program, shader_id);
    free(path);
    path = construct_asset_path(object->object_name, "fragment.shader");
    if(!load_shader(path, &shader_id, GL_FRAGMENT_SHADER)) {
        message_log("Error loading vertex shader-", object->object_name);
        free(path);
        return false;
    }
    glAttachShader(object->shader_program, shader_id);
    free(path);

    glLinkProgram(object->shader_program);

    return true;
}

void take_screenshot(Texture* screen) {
    //construct path TODO: better way to do string nonsense?
    char* datetime_string = get_datetime_string();
    int output_path_length = 255+strlen(datetime_string);
    char* output_path = malloc(sizeof(char)*output_path_length);
    sprintf(output_path, "%s/renderer - %s.png", State.OutputFolderPath, datetime_string);
    message_log("Taking screenshot-", output_path);

    //write screenshot
    glReadPixels(0, 0, screen->width, screen->height,
        GL_RGB, GL_UNSIGNED_BYTE, screen->buffer);
    flip_texture(screen);
    lodepng_encode24_file(output_path, (const unsigned char*)screen->buffer,
        screen->width, screen->height);

    free(datetime_string);
    free(output_path);
}
