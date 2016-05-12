//Inputs
attribute vec3 surface_normal;
attribute vec3 surface_tangent;

//Outputs
varying vec2 texture_coordinate;
varying vec3 local_normal;
varying vec3 local_tangent;

void main() {
    // Transforming The Vertex
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texture_coordinate = vec2(gl_MultiTexCoord0);
    local_normal = surface_normal;
    local_tangent = surface_tangent;
}
