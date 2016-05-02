#include "ruby.h"

#include "c_optimization_main.h"
#include "c_wavefront.h"
#include "c_point.h"

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
    Point* new_point; new_point = ALLOC(Point); set_point(new_point, 0.0, 0.0, 0.0);
    vertex->screen_v = new_point;
    return self;
}
VALUE C_Vertex_v(VALUE self) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    return Data_Wrap_Struct(C_Point, NULL, deallocate_struct, vertex->v);
}
VALUE C_Vertex_uv(VALUE self) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    return Data_Wrap_Struct(C_Point, NULL, deallocate_struct, vertex->uv);
}
VALUE C_Vertex_normal(VALUE self) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    return Data_Wrap_Struct(C_Point, NULL, deallocate_struct, vertex->normal);
}
VALUE C_Vertex_tangent(VALUE self) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    return Data_Wrap_Struct(C_Point, NULL, deallocate_struct, vertex->tangent);
}
VALUE C_Vertex_bitangent(VALUE self) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    return Data_Wrap_Struct(C_Point, NULL, deallocate_struct, vertex->bitangent);
}

VALUE C_Vertex_set_v(VALUE self, VALUE rb_point) {
    Vertex* vertex; Data_Get_Struct(self, Vertex, vertex);
    Point* point; Data_Get_Struct(rb_point, Point, point);
    vertex->v->x = point->x;
    vertex->v->y = point->y;
    vertex->v->z = point->z;
    return self;
}

//C_Face
VALUE C_Face_allocate(VALUE klass) {
    face* face; face = ALLOC(Face);
    return Data_Wrap_Struct(klass, NULL, deallocate_struct, face);
}

VALUE C_Face_initialize(VALUE self,
                    VALUE rb_vertex_a, VALUE rb_vertex_b, VALUE rb_vertex_c) {
    Face* face; Data_Get_Struct(self, Face, face);
    Vertex* vertex_a; Data_Get_Struct(rb_vertex_a, Vertex, vertex_a);
    Vertex* vertex_b; Data_Get_Struct(rb_vertex_b, Vertex, vertex_b);
    Vertex* vertex_c; Data_Get_Struct(rb_vertex_c, Vertex, vertex_c);
    Face->a = vertex_a;
    Face->b = vertex_b;
    Face->c = certex_c;
    return self;
}
