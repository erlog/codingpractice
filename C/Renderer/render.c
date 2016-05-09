bool should_not_draw_triangle(Point* a, Point* b, Point* c) {
    int area = (int)( (a->x*b->y) + (b->x*c->y) +
                    (c->x*a->y) - (a->y*b->x) - (b->y*c->x) - (c->y*a->x) );

    if(area == 0) { return true; } //points are colinear, not a triangle
    return false;
}


Point* compute_triangle_d(Point* a, Point* b, Point* c) {
    //for splitting triangles into 2 flat-bottomed triangles
    Point* result = allocate_point(
        floor(a->x + ( (b->y - a->y) / (c->y - a->y) ) * (c->x - a->x)),
        b->y, 1.0, 0.0);
    return result;
}

float compute_x(Point* src, Point* dest, float y) {
    //finds the x value for a given y value that lies between 2 points
    if(y == dest->y) { return dest->x; }; if(y == src->y) { return src->x; }
    float amt = (y - src->y)/(dest->y - src->y);
    return roundf(src->x + ( (dest->x - src->x) * amt ));
}

int triangle(Point** point_list, Point* a, Point* b, Point* c) {
    int number_of_points = 3;
    if(should_not_draw_triangle(a, b, c)) {
        Point* results = malloc(sizeof(Point)*number_of_points);
        *point_list = results;

        Point* one = allocate_point(1.0, 0.0, 0.0, 0.0);
        Point* two = allocate_point(0.0, 1.0, 0.0, 0.0);
        Point* three = allocate_point(0.0, 0.0, 1.0, 0.0);
        results[0] = *one; results[1] = *two; results[2] = *three;
        return number_of_points;
    }

    float x; float y;
    float min_x; float max_x;
    int line_i; int point_i;
    Point* cart; Point* bary;
    Point* d = compute_triangle_d(a, b, c);


    int top_lines = a->y - b->y + 1; //inclusive
    int bottom_lines = b->y - c->y + 1; //inclusive
    float* top_mins = malloc(sizeof(float)*top_lines);
    float* top_maxes = malloc(sizeof(float)*top_lines);
    float* bottom_mins = malloc(sizeof(float)*bottom_lines);
    float* bottom_maxes = malloc(sizeof(float)*bottom_lines);

    //get our min_x and max_x for each line
    //top half
    line_i = 0;
    for(y = b->y; y <= a->y; y++) {
        min_x = compute_x(a, b, y); max_x = compute_x(a, d, y);
        sort_floats(&min_x, &max_x);
        top_mins[line_i] = min_x; top_maxes[line_i] = max_x;
        number_of_points += max_x - min_x + 1; //inclusive
        line_i++;
    }

    //bottom half
    line_i = 0;
    for(y = c->y; y <= b->y; y++) {
        min_x = compute_x(c, b, y); max_x = compute_x(c, d, y);
        sort_floats(&min_x, &max_x);
        bottom_mins[line_i] = min_x; bottom_maxes[line_i] = max_x;
        number_of_points += max_x - min_x + 1; //inclusive
        line_i++;
    }

    Point* results = malloc(sizeof(Point)*number_of_points);
    *point_list = results;

    //do our vertices
    Point* one = allocate_point(1.0, 0.0, 0.0, 0.0);
    Point* two = allocate_point(0.0, 1.0, 0.0, 0.0);
    Point* three = allocate_point(0.0, 0.0, 1.0, 0.0);
    results[0] = *one; results[1] = *two; results[2] = *three;

    //add our calculated barycentric coordinates
    //top half
    line_i = 0; point_i = 3;
    for(y = b->y; y <= a->y; y++) {
        min_x = top_mins[line_i]; max_x = top_maxes[line_i];
        for(x = min_x; x <= max_x; x++) {
            cart = ALLOC(Point); bary = ALLOC(Point);
            point_set(cart, x, y, 1.0, 0.0);
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
            point_set(cart, x, y, 1.0, 0.0);
            cartesian_to_barycentric(cart, bary, a, b, c);
            results[point_i] = *bary;
            point_i++;
        }
        line_i++;
    }

    xfree(top_mins); xfree(top_maxes);
    xfree(bottom_mins); xfree(bottom_maxes);
    return number_of_points;
}

bool should_draw_face(Point* a_v, Point* b_v, Point* c_v,
                            float* normal_matrix, Point* camera_direction) {
    Point left;
    Point right;
    point_set(&left, b_v->x - a_v->x, b_v->y - a_v->y, b_v->z - a_v->z, 1.0);
    point_set(&right, c_v->x - a_v->x, c_v->y - a_v->y, c_v->z - a_v->z, 1.0);

    Point* normal = cross_product(&left, &right); normalize(normal);
    apply_matrix(normal, normal_matrix);
    float result = scalar_product(normal, camera_direction);

    xfree(normal);
    if(result < 0) { return true; } //this means the polygon isn't facing us
    return false;
}

void sort_vertices(Vertex** a, Vertex** b, Vertex** c) {
    Vertex* extra;
    if((*c)->screen_v->y > (*b)->screen_v->y) {
        extra = *b; *b = *c; *c = extra;
    }
    if(((*c)->screen_v->y == (*b)->screen_v->y) &&
                                    ((*c)->screen_v->x < (*b)->screen_v->x)) {
        extra = *b; *b = *c; *c = extra;
    }
    if((*b)->screen_v->y > (*a)->screen_v->y) {
        extra = *a; *a = *b; *b = extra;
    }
    if(((*b)->screen_v->y == (*a)->screen_v->y) &&
                                    ((*b)->screen_v->x < (*a)->screen_v->x)) {
        extra = *a; *a = *b; *b = extra;
    }
    if((*c)->screen_v->y > (*b)->screen_v->y) {
        extra = *b; *b = *c; *c = extra;
    }
    if(((*c)->screen_v->y == (*b)->screen_v->y) &&
                                    ((*c)->screen_v->x < (*b)->screen_v->x)) {
        extra = *b; *b = *c; *c = extra;
    }
    return;
}

void face_to_screen(Vertex* a, Vertex* b, Vertex* c,
                                float* view_matrix, Point* screen_center) {
    point_copy(a->v, a->screen_v);
    point_copy(b->v, b->screen_v);
    point_copy(c->v, c->screen_v);
    apply_matrix(a->screen_v, view_matrix);
    apply_matrix(b->screen_v, view_matrix);
    apply_matrix(c->screen_v, view_matrix);
    point_to_screen(a->screen_v, screen_center);
    point_to_screen(b->screen_v, screen_center);
    point_to_screen(c->screen_v, screen_center);
    return;
}

//TODO: write a face struct so I can get rid of the Ruby calls here
int render_model(VALUE rb_faces,
                float* view_matrix, float* normal_matrix,
                Point* camera_direction, Point* light_direction,
                Bitmap* bitmap, ZBuffer* zbuffer,
                Bitmap* texture, NormalMap* normalmap, SpecularMap* specmap) {

    Point* screen_center =
        allocate_point((float)(bitmap->width/2),(float)(bitmap->height/2), 255.0, 0.0);
    Point* texture_size =
        allocate_point((float)(texture->width-1),(float)(texture->height-1), 0.0, 0.0);

    int number_of_faces = RARRAY_LEN(rb_faces);
    int drawn_faces = 0;
    int number_of_points;
    int face_i; int point_i;
    Color color = pack_color(255, 255, 255, 255);
    VALUE face;
    Vertex* a; Vertex* b; Vertex* c;
    Point* bary;
    Point* screen_coord; screen_coord = ALLOC(Point);
    Point* texture_coord; texture_coord = ALLOC(Point);
    Point* tangent_normal;
    Point* normal; normal = ALLOC(Point);
    Point* point_list;
    float diffuse_intensity;
    float specular_power;
    float reflectivity;
    float factor;

    for(face_i = 0; face_i < number_of_faces; face_i++) {
        face = rb_ary_entry(rb_faces, face_i);
        Data_Get_Struct(rb_ary_entry(face, 0), Vertex, a);
        Data_Get_Struct(rb_ary_entry(face, 1), Vertex, b);
        Data_Get_Struct(rb_ary_entry(face, 2), Vertex, c);


        if(should_draw_face(a->v, b->v, c->v, normal_matrix,
                                                        camera_direction)) {
            drawn_faces++;
            //project face to screen
            face_to_screen(a, b, c, view_matrix, screen_center);
            sort_vertices(&a, &b, &c);

            number_of_points = triangle(&point_list, a->screen_v,
                                                    b->screen_v, c->screen_v);

            for(point_i = 0; point_i < number_of_points; point_i++) {
                bary = &point_list[point_i];
                barycentric_to_cartesian(bary, screen_coord, a->screen_v,
                                                    b->screen_v, c->screen_v);
                screen_coord->x = roundf(screen_coord->x);
                screen_coord->y = roundf(screen_coord->y);
                //convert to clip coordinates
                to_barycentric_clip(bary, a->screen_v, b->screen_v, c->screen_v);

                if(zbuffer_should_draw(zbuffer, screen_coord)) {
                    point_to_texture(bary, texture_coord, texture_size,
                                                        a->uv, b->uv, c->uv);
                    //compute diffuse from tangent normal
                    tangent_normal = get_normal(normalmap, texture_coord);
                    convert_tangent_normal(tangent_normal, bary,
                                            normal, normal_matrix, a, b, c);
                    diffuse_intensity = scalar_product(normal,
                                                        light_direction) * -1;
                    diffuse_intensity = clamp_float(diffuse_intensity, 0.0, 1.0);
                    //compute specularity
                    specular_power = get_specular(specmap, texture_coord);
                    reflectivity = compute_reflection(normal, light_direction,
                                            camera_direction, specular_power);
                    //light our pixel with the information
                    color = bitmap_get_pixel(texture, texture_coord);
                    factor = 0.05 + 0.6*reflectivity + 0.75*diffuse_intensity;
                    color = color_multiply(color, factor);
                    bitmap_set_pixel(bitmap, screen_coord, color);
                }
            }
            xfree(point_list);
        }
    }
    xfree(screen_center);
    xfree(texture_size);
    xfree(normal);
    xfree(screen_coord);
    xfree(texture_coord);

    return(drawn_faces);
}

//TODO: Is this dead code?
VALUE rb_render_model(VALUE self, VALUE rb_faces,
                VALUE rb_view_matrix, VALUE rb_normal_matrix,
                VALUE rb_camera_direction, VALUE rb_light_direction,
                VALUE rb_bitmap, VALUE rb_zbuffer,
                VALUE rb_texture, VALUE rb_normalmap, VALUE rb_specmap) {

    Bitmap* bitmap; Data_Get_Struct(rb_bitmap, Bitmap, bitmap);
    Bitmap* texture; Data_Get_Struct(rb_texture, Bitmap, texture);
    ZBuffer* zbuffer; Data_Get_Struct(rb_zbuffer, ZBuffer, zbuffer);
    NormalMap* normalmap; Data_Get_Struct(rb_normalmap, NormalMap, normalmap);
    SpecularMap* specmap; Data_Get_Struct(rb_specmap, SpecularMap, specmap);

    Matrix* matrix_struct;
    Data_Get_Struct(rb_view_matrix, Matrix, matrix_struct);
    float* view_matrix = matrix_struct->m;
    Data_Get_Struct(rb_normal_matrix, Matrix, matrix_struct);
    float* normal_matrix = matrix_struct->m;

    Point* camera_direction; Data_Get_Struct(rb_camera_direction, Point, camera_direction);
    Point* light_direction; Data_Get_Struct(rb_light_direction, Point, light_direction);

    int drawn_faces = render_model(rb_faces, view_matrix, normal_matrix,
        camera_direction, light_direction, bitmap, zbuffer, texture, normalmap,
        specmap);

    return INT2NUM(drawn_faces);
}
