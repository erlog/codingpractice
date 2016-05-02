//Small functions with no dependencies that don't fit anywhere else
char* debug_bitmap_output_string(char* string) {
    time_t now; struct tm* timeinfo;
    time(&now); timeinfo = localtime(&now);
    strftime(string, 79, "output/renderer - %Y-%m-%d %H:%M:%S.bmp",timeinfo);
    return string;
}

char* object_file_path(char* file_path, char* object_name) {
    sprintf(file_path, "objects/%s/object.obj", object_name);
}
