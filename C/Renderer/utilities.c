//Small functions with no dependencies that don't fit anywhere else
void compute_matrices(float x, float y, float z, float projection,
    float** view_matrix, float** normal_matrix) {
    VALUE rb_result = rb_funcall(rb_cObject, rb_intern("compute_matrices"), 4,
        DBL2NUM(x), DBL2NUM(y), DBL2NUM(z), DBL2NUM(projection));
    Matrix* matrix_struct;
    Data_Get_Struct(rb_ary_entry(rb_result, 0), Matrix, matrix_struct);
    *view_matrix = matrix_struct->m;
    Data_Get_Struct(rb_ary_entry(rb_result, 1), Matrix, matrix_struct);
    *normal_matrix = matrix_struct->m;
    return;
}

void load_model(char* model_name, Faces* faces, Bitmap** texture,
    NormalMap** normalmap, SpecularMap** specmap) {

    VALUE object_name = rb_str_new_cstr(model_name);
    VALUE rb_result = rb_funcall(rb_cObject, rb_intern("load_object"), 1, object_name);

    VALUE rb_faces = rb_ary_entry(rb_result, 0);
    int number_of_faces = RARRAY_LEN(rb_faces);
    faces->array = malloc(sizeof(Face)*number_of_faces);
    faces->length = number_of_faces;
    int i;
    Face* face;
    for(i = 0; i < number_of_faces; i++) {
        Data_Get_Struct(rb_ary_entry(rb_faces, i), Face, face);
        faces->array[i] = *face;
    }
    Data_Get_Struct(rb_ary_entry(rb_result, 1), Bitmap, *texture);
    Data_Get_Struct(rb_ary_entry(rb_result, 2), NormalMap, *normalmap);
    Data_Get_Struct(rb_ary_entry(rb_result, 3), SpecularMap, *specmap);
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
