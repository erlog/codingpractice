varying vec2 texture_coordinate;
varying vec3 surface_normal;

void main() {
    // Transforming The Vertex
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    // Passing The Texture Coordinate Of Texture Unit 0 To The Fragment Shader
    texture_coordinate = vec2(gl_MultiTexCoord0);
    surface_normal = gl_Normal;
}
