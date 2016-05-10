//Generics
void deallocate_struct(void* my_struct) {
    xfree(my_struct);
    return;
}

void ruby_setup_render_environment() {
    RUBY_INIT_STACK;
    ruby_init();

    //ruby is stupid and won't initialize encodings
    char *dummy_argv[] = {"vim-ruby", "-e0"};
    ruby_options(2, dummy_argv);

    ruby_script("renderer");
    ruby_init_loadpath();
    /*
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

    VALUE C_Face = rb_define_class("C_Face", rb_cObject);
    rb_define_alloc_func(C_Face, C_Face_allocate);
    rb_define_method(C_Face, "initialize", C_Face_initialize, 3);
    */
    rb_require("./main.rb");
}
