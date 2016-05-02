#ifndef C_DRAWING_H
#define C_DRAWING_H

VALUE C_triangle(VALUE self, VALUE rb_verts);
int triangle(Point** point_list, Point* a, Point* b, Point* c);

#endif
