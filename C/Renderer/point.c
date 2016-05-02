void deallocate_point(Point* point) {
    free(point);
}

Point* allocate_point(float x, float y, float z, float q) {
    Point* point; point = malloc(sizeof(Point));
    point->x = x; point->y = y; point->z = z; point->q = q;
    return point;
}

void point_print(Point* point) {
    printf("Point: (%f, %f, %f)\n", point->x, point->y, point->z);
}
