#include "ruby.h"
#include "stdbool.h"

#include "c_drawing.h"
#include "c_optimization_main.h"
#include "c_point.h"

inline bool should_not_draw_triangle(Point* a, Point* b, Point* c) {
    int area = (int)( (a->x*b->y) + (b->x*c->y) +
                    (c->x*a->y) - (a->y*b->x) -
                    (b->y*c->x) - (c->y*a->x) );

    if(area == 0) { return true; } //points are colinear, not a triangle
    return false;
}


inline Point* compute_triangle_d(Point* a, Point* b, Point* c) {
    //for splitting triangles into 2 flat-bottomed triangles
    Point* result; result = ALLOC(Point);
    result->x = floor(a->x + ( (b->y - a->y) / (c->y - a->y) ) * (c->x - a->x));
    result->y = b->y;
    result->z = 1;
    return result;
}

inline double compute_x(Point* src, Point* dest, double y) {
    //finds the x value for a given y value that lies between 2 points
    if(y == dest->y) { return dest->x; }; if(y == src->y) { return src->x; }
    double amt = (y - src->y)/(dest->y - src->y);
    return roundf(src->x + ( (dest->x - src->x) * amt ));
}

VALUE C_triangle(VALUE self, VALUE rb_verts) {
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    //declare the reference triangle
    Point* bary_a; bary_a = ALLOC(Point); set_point(bary_a, 1.0, 0.0, 0.0);
    Point* bary_b; bary_b = ALLOC(Point); set_point(bary_b, 0.0, 1.0, 0.0);
    Point* bary_c; bary_c = ALLOC(Point); set_point(bary_c, 0.0, 0.0, 1.0);

    //declare the point object we're yielding
    Point* bary; bary = ALLOC(Point);
    VALUE rb_bary = Data_Wrap_Struct(rb_class_of(rb_ary_entry(rb_verts, 0)),
                                                NULL, deallocate_struct, bary);

    //yield our vertices
    set_point(bary, 1.0, 0.0, 0.0); rb_yield(rb_bary);
    set_point(bary, 0.0, 1.0, 0.0); rb_yield(rb_bary);
    set_point(bary, 0.0, 0.0, 1.0); rb_yield(rb_bary);

    int i;
    int length;

    //yield our wireframe
    length = line_length(a, b); //we already yielded the vertex
    for(i = length-1; i > 0; i--) {
        lerp(bary_a, bary_b, bary, i/(float)length); rb_yield(rb_bary);
    }
    length = line_length(b, c); //we already yielded the vertex
    for(i = length-1; i > 0; i--) {
        lerp(bary_b, bary_c, bary, i/(float)length); rb_yield(rb_bary);
    }
    length = line_length(a, c); //we already yielded the vertex
    for(i = length-1; i > 0; i--) {
        lerp(bary_a, bary_c, bary, i/(float)length); rb_yield(rb_bary);
    }
    if(should_not_draw_triangle(a, b, c)) { return Qnil; }

    Point* d = compute_triangle_d(a, b, c);
    Point* cart; cart = ALLOC(Point);
    double x; double y;
    double min_x; double max_x;

    //draw top half of triangle
    for(y = b->y; y <= a->y; y++) {
        min_x = compute_x(a, b, y); max_x = compute_x(a, d, y);
        sort_doubles(&min_x, &max_x);
        for(x = min_x; x <= max_x; x++) {
            set_point(cart, x, y, 1);
            cartesian_to_barycentric(cart, bary, a, b, c);
            if(does_not_contain_negative(bary)) { rb_yield(rb_bary); }
        }
    }

    //draw bottom half of triangle
    for(y = c->y; y <= b->y; y++) {
        min_x = compute_x(c, b, y); max_x = compute_x(c, d, y);
        sort_doubles(&min_x, &max_x);
        for(x = min_x; x <= max_x; x++) {
            set_point(cart, x, y, 1);
            cartesian_to_barycentric(cart, bary, a, b, c);
            if(does_not_contain_negative(bary)) { rb_yield(rb_bary); }
        }
    }

    return Qnil;
}
