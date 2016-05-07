//Generics
void deallocate_struct(void* my_struct) {
    xfree(my_struct);
    return;
}

//C_Point
VALUE C_Point_allocate(VALUE klass) {
    Point* point; point = ALLOC(Point);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, point);
}
VALUE C_Point_initialize(VALUE self, VALUE x, VALUE y, VALUE z) {
    Point* point; Data_Get_Struct(self, Point, point);
    point->x = NUM2DBL(x); point->y = NUM2DBL(y); point->z = NUM2DBL(z);
    point->q = 1.0;
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
    Point* new_point; new_point = ALLOC(Point);
    new_point->x = 0.0; new_point->y = 0.0; new_point->z = 0.0; new_point->q = 0.0;
    vertex->screen_v = new_point;
    return self;
}

void ruby_setup_render_environment() {
    ruby_init();
    ruby_init_loadpath();
    rb_require("./wavefront.rb");

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
}
