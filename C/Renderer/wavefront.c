void point_print(Point* point) {
    printf("Point: %f, %f, %f\n", point->x, point->y, point->z);
    return;
}

Point parse_point_string(char* line) {
    Point point;
    int i = 0; while(line[i] == 0x20) { i++; }
    float x; float y; float z;
    sscanf(&line[i], "%f %f %f", &x, &y, &z);
    point.x = (GLfloat)x; point.y = (GLfloat)y; point.z = (GLfloat)z;
    return point;
}

int parse_face_triplet(char* line, int* result) {
    int i = 0; while(line[i] == 0x20) { i++; }
    sscanf(&line[i], "%i/%i/%i", &result[0], &result[1], &result[2]);
    result[0]--; result[1]--; result[2]--; //wavefront files are 1-indexed
    return i;
}

bool load_model(char* object_name, Model* model) {
    //Load file
    model->asset_path = construct_asset_path(object_name, "object.obj");
    char buffer[255]; FILE* file = fopen(model->asset_path, "r");
    if(file == NULL) { message_log("Error loading file"); return false; }

    char* vertex_label = "v"; char* uv_label = "vt";
    char* normal_label = "vn"; char* face_label = "f";

    //Count number of items
    int vertex_count = 0; int uv_count = 0;
    int normal_count = 0; int face_count = 0;

    while(fgets(buffer, sizeof(buffer), file) != NULL) {
        if(strncmp(buffer, uv_label, strlen(uv_label)) == 0) {
            uv_count++;
        }
        else if(strncmp(buffer, normal_label, strlen(normal_label)) == 0) {
            normal_count++;
        }
        else if(strncmp(buffer, vertex_label, strlen(vertex_label)) == 0) {
            vertex_count++;
        }
        else if(strncmp(buffer, face_label, strlen(face_label)) == 0) {
            face_count++;
        }
    }
    fseek(file, 0, SEEK_SET);
    Point* vertices = malloc(sizeof(Point)*vertex_count); vertex_count = 0;
    Point* uvs = malloc(sizeof(Point)*uv_count); uv_count = 0;
    Point* normals = malloc(sizeof(Point)*normal_count); normal_count = 0;

    model->face_count = face_count;
    Face* faces = malloc(sizeof(Face)*face_count); face_count = 0;
    model->faces = faces;

    //Read data
    while(fgets(buffer, sizeof(buffer), file) != NULL) {
        if(strncmp(buffer, uv_label, strlen(uv_label)) == 0) {
            uvs[uv_count] = parse_point_string(buffer+strlen(uv_label));
            uvs[uv_count].id = uv_count;
            uv_count++;
        }
        else if(strncmp(buffer, normal_label, strlen(normal_label)) == 0) {
            normals[normal_count] =
                parse_point_string(buffer+strlen(normal_label));
            normals[normal_count].id = normal_count;
            normal_count++;
        }
        else if(strncmp(buffer, vertex_label, strlen(vertex_label)) == 0) {
            vertices[vertex_count] =
                parse_point_string(buffer+strlen(vertex_label));
            vertices[vertex_count].id = vertex_count;
            vertex_count++;
        }
        else if(strncmp(buffer, face_label, strlen(face_label)) == 0) {
            int triplet[3]; int i = strlen(face_label);
            i += parse_face_triplet(&buffer[i], &triplet[0]);
            faces[face_count].a.v = vertices[triplet[0]];
            faces[face_count].a.uv = uvs[triplet[1]];
            faces[face_count].a.n = normals[triplet[2]];
            while(buffer[i] != 0x20) { i++; }
            i += parse_face_triplet(&buffer[i], &triplet[0]);
            faces[face_count].b.v = vertices[triplet[0]];
            faces[face_count].b.uv = uvs[triplet[1]];
            faces[face_count].b.n = normals[triplet[2]];
            while(buffer[i] != 0x20) { i++; }
            i += parse_face_triplet(&buffer[i], &triplet[0]);
            faces[face_count].c.v = vertices[triplet[0]];
            faces[face_count].c.uv = uvs[triplet[1]];
            faces[face_count].c.n = normals[triplet[2]];

            face_count++;
        }
    }
    free(vertices); free(uvs); free(normals);
    return true;
}
