//Small functions that don't fit anywhere else with minimal dependencies
char* construct_asset_path(char* object_name, char* filename) {
    int asset_path_length = strlen(AssetFolderPath) + strlen(object_name) +
        strlen(filename) + 1;
    char* asset_path = malloc(sizeof(char)*asset_path_length);
    sprintf(asset_path, "%s/%s/%s", AssetFolderPath, object_name, filename);
    return asset_path;
}

void message_log(char* message) {
    printf("Log: %s\n", message);
}

bool load_texture(char* object_name, Texture* texture) {
    texture->asset_path = construct_asset_path(object_name, "diffuse.png");
    //Load PNG
    unsigned width; unsigned height;
    if(lodepng_decode32_file(&texture->buffer, &width, &height,
        texture->asset_path)) { message_log("Error loading PNG"); return false;}
    //Register our texture with OpenGL
    //TODO: error handling
    texture->width = (GLsizei)width; texture->height = (GLsizei)height;
    glGenTextures(1, &texture->texture_id);
    glBindTexture(GL_TEXTURE_2D, texture->texture_id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture->width, texture->height, 0,
         GL_RGBA, GL_UNSIGNED_BYTE, texture->buffer);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glBindTexture(GL_TEXTURE_2D, 0); //unbind the texture
    return true;
}

void load_object(Object* object) {
    object->texture = malloc(sizeof(Texture));
    if(!load_texture(object->object_name, object->texture)) {
        message_log("Error loading texture");
    }
    object->model = malloc(sizeof(Model));
    if(!load_model(object->object_name, object->model)) {
        message_log("Error loading model");
    }
    return;
}

float clamp_float(float value, float min, float max) {
    if(value > max) { return max; }
    if(value < min) { return min; }
    return value;
}

void sort_floats(float* a, float* b) {
    float backup = *a;
    if (*a > *b) { *a = *b; *b = backup; }
    return;
}
