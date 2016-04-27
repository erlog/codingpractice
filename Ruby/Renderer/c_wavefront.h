#ifndef C_WAVEFRONT_H
#define C_WAVEFRONT_H

//C_Vertex
VALUE C_Vertex_allocate(VALUE klass);

VALUE C_Vertex_initialize(VALUE self, VALUE rb_v, VALUE rb_uv,
                       VALUE rb_normal, VALUE rb_tangent, VALUE rb_bitangent);
VALUE C_Vertex_v(VALUE self);
VALUE C_Vertex_uv(VALUE self);
VALUE C_Vertex_normal(VALUE self);
VALUE C_Vertex_tangent(VALUE self);
VALUE C_Vertex_bitangent(VALUE self);
VALUE C_Vertex_set_v(VALUE self, VALUE rb_point);

#endif
