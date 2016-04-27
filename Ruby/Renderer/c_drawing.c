#include "ruby.h"
#include "stdbool.h"

#include "c_optimization_main.h"
#include "c_wavefront.h"
#include "c_point.h"
#include "c_drawing.h"

inline bool should_not_draw_triangle(Point* a, Point* b, Point* c) {
    int area = (int)( (a->x*b->y) + (b->x*c->y) +
                    (c->x*a->y) - (a->y*b->x) - (b->y*c->x) - (c->y*a->x) );

    if(area == 0) { return true; } //points are colinear, not a triangle
    return false;
}


inline Point* compute_triangle_d(Point* a, Point* b, Point* c) {
    //for splitting triangles into 2 flat-bottomed triangles
    Point* result; result = ALLOC(Point);
    result->x = floor(a->x + ( (b->y - a->y) / (c->y - a->y) ) * (c->x - a->x));
    result->y = b->y;
    result->z = 1.0;
    return result;
}

inline double compute_x(Point* src, Point* dest, double y) {
    //finds the x value for a given y value that lies between 2 points
    if(y == dest->y) { return dest->x; }; if(y == src->y) { return src->x; }
    double amt = (y - src->y)/(dest->y - src->y);
    return roundf(src->x + ( (dest->x - src->x) * amt ));
}

int triangle(Point** point_list, Point* a, Point* b, Point* c) {
    int number_of_points = 3;
    if(should_not_draw_triangle(a, b, c)) {
        Point* results = malloc(sizeof(Point)*number_of_points);
        *point_list = results;

        Point* one; one = ALLOC(Point); set_point(one, 1.0, 0.0, 0.0);
        Point* two; two = ALLOC(Point); set_point(two, 0.0, 1.0, 0.0);
        Point* three; three = ALLOC(Point); set_point(three, 0.0, 0.0, 1.0);
        results[0] = *one; results[1] = *two; results[2] = *three;
        return number_of_points;
    }

    double x; double y;
    double min_x; double max_x;
    int line_i; int point_i;
    Point* cart; Point* bary;
    Point* d = compute_triangle_d(a, b, c);


    int top_lines = a->y - b->y + 1; //inclusive
    int bottom_lines = b->y - c->y + 1; //inclusive
    double* top_mins = malloc(sizeof(double)*top_lines);
    double* top_maxes = malloc(sizeof(double)*top_lines);
    double* bottom_mins = malloc(sizeof(double)*bottom_lines);
    double* bottom_maxes = malloc(sizeof(double)*bottom_lines);

    //get our min_x and max_x for each line
    //top half
    line_i = 0;
    for(y = b->y; y <= a->y; y++) {
        min_x = compute_x(a, b, y); max_x = compute_x(a, d, y);
        sort_doubles(&min_x, &max_x);
        top_mins[line_i] = min_x; top_maxes[line_i] = max_x;
        number_of_points += max_x - min_x + 1; //inclusive
        line_i++;
    }

    //bottom half
    line_i = 0;
    for(y = c->y; y <= b->y; y++) {
        min_x = compute_x(c, b, y); max_x = compute_x(c, d, y);
        sort_doubles(&min_x, &max_x);
        bottom_mins[line_i] = min_x; bottom_maxes[line_i] = max_x;
        number_of_points += max_x - min_x + 1; //inclusive
        line_i++;
    }

    Point* results = malloc(sizeof(Point)*number_of_points);
    *point_list = results;

    //do our vertices
    Point* one; one = ALLOC(Point); set_point(one, 1.0, 0.0, 0.0);
    Point* two; two = ALLOC(Point); set_point(two, 0.0, 1.0, 0.0);
    Point* three; three = ALLOC(Point); set_point(three, 0.0, 0.0, 1.0);
    results[0] = *one; results[1] = *two; results[2] = *three;

    //add our calculated barycentric coordinates
    //top half
    line_i = 0; point_i = 3;
    for(y = b->y; y <= a->y; y++) {
        min_x = top_mins[line_i]; max_x = top_maxes[line_i];
        for(x = min_x; x <= max_x; x++) {
            cart = ALLOC(Point); bary = ALLOC(Point);
            set_point(cart, x, y, 1.0);
            cartesian_to_barycentric(cart, bary, a, b, c);
            results[point_i] = *bary;
            point_i++;
        }
        line_i++;
    }

    //bottom half
    line_i = 0;
    for(y = c->y; y <= b->y; y++) {
        min_x = bottom_mins[line_i]; max_x = bottom_maxes[line_i];
        for(x = min_x; x <= max_x; x++) {
            cart = ALLOC(Point); bary = ALLOC(Point);
            set_point(cart, x, y, 1.0);
            cartesian_to_barycentric(cart, bary, a, b, c);
            results[point_i] = *bary;
            point_i++;
        }
        line_i++;
    }

    free(top_mins); free(top_maxes);
    free(bottom_mins); free(bottom_maxes);
    return number_of_points;
}

VALUE C_triangle(VALUE self, VALUE rb_verts) {
    Point* a; Data_Get_Struct(rb_ary_entry(rb_verts, 0), Point, a);
    Point* b; Data_Get_Struct(rb_ary_entry(rb_verts, 1), Point, b);
    Point* c; Data_Get_Struct(rb_ary_entry(rb_verts, 2), Point, c);

    //declare the point object we're yielding
    Point* bary; bary = ALLOC(Point);
    VALUE rb_bary = Data_Wrap_Struct(rb_class_of(rb_ary_entry(rb_verts, 0)),
                                                NULL, deallocate_struct, bary);
    Point* point_list;

    int number_of_points = triangle(&point_list, a, b, c);

    int point_i;
    for(point_i = 0; point_i < number_of_points; point_i++) {
        point_clone(&point_list[point_i], bary);
        rb_yield(rb_bary);
    }

    free(point_list);
    return Qnil;
}
