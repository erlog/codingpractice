#ifndef C_DRAWING_H
#define C_DRAWING_H

void lerp(Point* src, Point* dest, Point* result, double amt);
double line_length(Point* src, Point* dest);
VALUE C_triangle(VALUE self, VALUE rb_verts);

#endif
