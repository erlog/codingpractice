void deallocate_point(Point* point) {
    xfree(point);
}

void point_print(Point* point) {
    printf("Point: (%f, %f, %f)\n", point->x, point->y, point->z);
}

void point_set(Point* point, float x, float y, float z, float q) {
    point->x = x; point->y = y; point->z = z; point->q = q;
    return;
}

Point* allocate_point(float x, float y, float z, float q) {
    Point* point; point = ALLOC(Point); point_set(point, x, y, z, q);
    return point;
}

void point_copy(Point* src, Point* dest) {
    dest->x = src->x; dest->y = src->y; dest->z = src->z; dest->q = src->q;
    return;
}


void apply_matrix(Point* point, float* m) {
    float x = (m[0] * point->x) + (m[1] * point->y) + (m[2] * point->z) + m[3];
    float y = (m[4] * point->x) + (m[5] * point->y) + (m[6] * point->z) + m[7];
    float z = (m[8] * point->x) + (m[9] * point->y) + (m[10] * point->z) + m[11];
    float q = (m[12] * point->x) + (m[13] * point->y) + (m[14] * point->z) + m[15];
    point->x = x/q; point->y = y/q; point->z = z/q; point->q = q;
    return;
}

Point* cross_product(Point* point_a, Point* point_b) {
    float x = (point_a->y * point_b->z) - (point_a->z * point_b->y);
    float y = (point_a->z * point_b->x) - (point_a->x * point_b->z);
    float z = (point_a->x * point_b->y) - (point_a->y * point_b->x);
    return allocate_point(x, y, z, 0.0);
}

float scalar_product(Point* point_a, Point* point_b) {
    float result = (point_a->x*point_b->x) +
                    (point_a->y*point_b->y) +
                    (point_a->z*point_b->z);
    return result;
}

void cartesian_to_barycentric(Point* cart, Point* result,
    Point* a, Point* b, Point* c) {

    Point* vec_one = allocate_point(c->x - a->x, b->x - a->x, a->x - cart->x, 0);
    Point* vec_two = allocate_point(c->y - a->y, b->y - a->y, a->y - cart->y, 0);
    Point* vec_u = cross_product(vec_one, vec_two);

    float x = clamp_float(1.0 - ((vec_u->x + vec_u->y) / vec_u->z), 0.0, 1.0);
    float y = clamp_float(vec_u->y / vec_u->z, 0.0, 1.0);
    float z = clamp_float(vec_u->x / vec_u->z, 0.0, 1.0);
    float total = x + y + z;

    result->x = x/total; result->y = y/total; result->z = z/total;

    xfree(vec_one); xfree(vec_two); xfree(vec_u);
    return;
}

void barycentric_to_cartesian(Point* bary, Point* result,
    Point* a, Point* b, Point* c) {

    float x = (a->x * bary->x) + (b->x * bary->y) + (c->x * bary->z);
    float y = (a->y * bary->x) + (b->y * bary->y) + (c->y * bary->z);
    float z = (a->z * bary->x) + (b->z * bary->y) + (c->z * bary->z);

    result->x = x; result->y = y; result->z = z;
    return;
}

void to_barycentric_clip(Point* bary, Point* a_v, Point* b_v, Point* c_v) {
    float x = bary->x/a_v->q;
    float y = bary->y/b_v->q;
    float z = bary->z/c_v->q;
    float total = x + y + z;

    bary->x = x/total; bary->y = y/total; bary->z = z/total;
    return;
}

void normalize(Point* point) {
    float length = sqrtf( pow(point->x,2) +
                    pow(point->y,2) +
                    pow(point->z,2) );
    point->x /= length; point->y /= length; point->z /= length;
    return;
}

void point_to_screen(Point* point, Point* center) {
    point->x = roundf(center->x + (point->x * center->y));
    point->y = roundf(center->y + (point->y * center->y));
    point->z = center->z + (point->z * center->z);
    return;
}

void point_to_texture(Point* point, Point* result, Point* texture_size,
                                                Point* a, Point* b, Point* c) {
    barycentric_to_cartesian(point, result, a, b, c);
    result->x = roundf(result->x * texture_size->x);
    result->y = roundf(result->y * texture_size->y);
    result->z = 0.0;
    return;
}

float compute_reflection(Point* normal, Point* light_direction,
                        Point* camera_direction, float specular_power) {
    float factor = scalar_product(normal, light_direction) * -2;
    Point* new_point = allocate_point((normal->x * factor) + normal->x,
        (normal->y * factor) + normal->y, (normal->z * factor) + normal->z, 0);
    normalize(new_point);
    float reflectivity = clamp_float((scalar_product(new_point, camera_direction)*-1), 0.0, 1.0);
    xfree(new_point);
    return pow(reflectivity, specular_power);
}

void convert_tangent_normal(Point* tangent_normal, Point* barycentric,
            Point* result, float* matrix, Vertex* a, Vertex* b, Vertex* c) {

    Point tangent; Point bitangent; Point normal;

    barycentric_to_cartesian(barycentric, &tangent,
                                        a->tangent, b->tangent, c->tangent);
    barycentric_to_cartesian(barycentric, &bitangent,
                                    a->bitangent, b->bitangent, c->bitangent);
    barycentric_to_cartesian(barycentric, &normal,
                                        a->normal, b->normal, c->normal);
    result->x = (tangent.x * tangent_normal->x) +
                (bitangent.x * tangent_normal->y) +
                (normal.x * tangent_normal->z);
    result->y = (tangent.y * tangent_normal->x) +
                (bitangent.y * tangent_normal->y) +
                (normal.y * tangent_normal->z);
    result->z = (tangent.z * tangent_normal->x) +
                (bitangent.z * tangent_normal->y) +
                (normal.z * tangent_normal->z);

    apply_matrix(result, matrix);
    normalize(result);

    return;
}
