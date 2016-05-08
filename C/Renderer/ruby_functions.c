//Generics
void deallocate_struct(void* my_struct) {
    xfree(my_struct);
    return;
}

//C_Matrix
VALUE C_Matrix_allocate(VALUE klass) {
    Matrix* matrix; matrix = ALLOC(Matrix);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, matrix);
}

VALUE C_Matrix_initialize(VALUE self, VALUE rb_array) {
    Matrix* matrix; Data_Get_Struct(self, Matrix, matrix);
    matrix->m = malloc(sizeof(float)*16);
    int i;
    for(i = 0; i < 16; i++) {
        matrix->m[i] = NUM2DBL(rb_ary_entry(rb_array, i));
    }
    return self;
}

//C_Point
VALUE C_Point_allocate(VALUE klass) {
    Point* point; point = ALLOC(Point);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, point);
}
VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z) {
    Point* point; Data_Get_Struct(self, Point, point);
    point_set(point, NUM2DBL(x), NUM2DBL(y), NUM2DBL(z), 1.0);
    return self;
}
VALUE C_Point_get_x(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->x);
}
VALUE C_Point_get_y(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->y);
}
VALUE C_Point_get_z(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point); return DBL2NUM(point->z);
}
VALUE C_Point_set_x(VALUE self, VALUE rb_value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = NUM2DBL(rb_value);
    return self;
}
VALUE C_Point_set_y(VALUE self, VALUE rb_value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->y = NUM2DBL(rb_value);
    return self;
}
VALUE C_Point_set_z(VALUE self, VALUE rb_value) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->z = NUM2DBL(rb_value);
    return self;
}
VALUE C_Point_scale_by_factor(VALUE self, VALUE value) {
    Point* point; Data_Get_Struct(self, Point, point);
    double factor = NUM2DBL(value);
    point->x *= factor; point->y *= factor; point->z *= factor;
    return self;
}
VALUE C_Point_normalize(VALUE self) {
    Point* point; Data_Get_Struct(self, Point, point);
    float length = sqrtf( pow(point->x,2) + pow(point->y,2) + pow(point->z,2) );
    point->x /= length; point->y /= length; point->z /= length;
    return self;
}

//C_Vertex
VALUE C_Vertex_allocate(VALUE klass) {
    //TODO: I think these might not be being deallocated correctly
    Vertex* vertex; vertex = ALLOC(Vertex);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, vertex);
}

VALUE C_Vertex_initialize(VALUE self, VALUE rb_v, VALUE rb_uv,
                       VALUE rb_normal, VALUE rb_tangent, VALUE rb_bitangent) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    Data_Get_Struct(rb_v, Point, vertex->v);
    Data_Get_Struct(rb_uv, Point, vertex->uv);
    Data_Get_Struct(rb_normal, Point, vertex->normal);
    Data_Get_Struct(rb_tangent, Point, vertex->tangent);
    Data_Get_Struct(rb_bitangent, Point, vertex->bitangent);

    //initialize screen_v
    vertex->screen_v = allocate_point(0.0, 0.0, 0.0, 0.0);
    return self;
}

void ruby_setup_render_environment() {
    RUBY_INIT_STACK;
    ruby_init();

    //ruby is stupid and won't initialize encodings
    char *dummy_argv[] = {"vim-ruby", "-e0"};
    ruby_options(2, dummy_argv);

    ruby_script("renderer");
    ruby_init_loadpath();

    rb_define_global_function("render_model", rb_render_model, 10);

    VALUE C_Point = rb_define_class("Point", rb_cObject);
    rb_define_alloc_func(C_Point, C_Point_allocate);
    rb_define_method(C_Point, "initialize", C_Point_initialize, 3);
    rb_define_method(C_Point, "x", C_Point_get_x, 0);
    rb_define_method(C_Point, "y", C_Point_get_y, 0);
    rb_define_method(C_Point, "z", C_Point_get_z, 0);
    rb_define_method(C_Point, "x=", C_Point_set_x, 1);
    rb_define_method(C_Point, "y=", C_Point_set_y, 1);
    rb_define_method(C_Point, "z=", C_Point_set_z, 1);
    rb_define_method(C_Point, "normalize", C_Point_normalize, 0);
    rb_define_method(C_Point, "scale_by_factor", C_Point_scale_by_factor, 1);

    VALUE C_Vertex = rb_define_class("C_Vertex", rb_cObject);
    rb_define_alloc_func(C_Vertex, C_Vertex_allocate);
    rb_define_method(C_Vertex, "initialize", C_Vertex_initialize, 5);

    VALUE C_Bitmap = rb_define_class("Bitmap", rb_cObject);
    rb_define_alloc_func(C_Bitmap, C_Bitmap_allocate);
    rb_define_method(C_Bitmap, "initialize", C_Bitmap_initialize, 3);
    rb_define_method(C_Bitmap, "set_pixel", C_Bitmap_set_pixel, 2);

    VALUE C_ZBuffer = rb_define_class("Z_Buffer", rb_cObject);
    rb_define_alloc_func(C_ZBuffer, C_ZBuffer_allocate);
    rb_define_method(C_ZBuffer, "initialize", C_ZBuffer_initialize, 2);
    rb_define_method(C_ZBuffer, "drawn_pixels", C_ZBuffer_drawn_pixels, 0);
    rb_define_method(C_ZBuffer, "oob_pixels", C_ZBuffer_oob_pixels, 0);
    rb_define_method(C_ZBuffer, "occluded_pixels", C_ZBuffer_occluded_pixels, 0);

    VALUE C_NormalMap = rb_define_class("NormalMap", rb_cObject);
    rb_define_alloc_func(C_NormalMap, C_NormalMap_allocate);
    rb_define_method(C_NormalMap, "initialize", C_NormalMap_initialize, 1);

    VALUE C_SpecularMap = rb_define_class("SpecularMap", rb_cObject);
    rb_define_alloc_func(C_SpecularMap, C_SpecularMap_allocate);
    rb_define_method(C_SpecularMap, "initialize", C_SpecularMap_initialize, 1);

    VALUE C_Matrix = rb_define_class("C_Matrix", rb_cObject);
    rb_define_alloc_func(C_Matrix, C_Matrix_allocate);
    rb_define_method(C_Matrix, "initialize", C_Matrix_initialize, 1);

    rb_require("./main.rb");
}
