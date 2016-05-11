varying vec2 texture_coordinate;
varying vec3 surface_normal;
uniform sampler2D diffuse;
uniform sampler2D normal;
uniform sampler2D specular;
vec3 light_direction;

void main() {
    gl_FragColor = texture2D(diffuse, texture_coordinate);
    light_direction = vec3(0.0f, 0.0f, 1.0f);
    float intensity = dot(light_direction, surface_normal);
    gl_FragColor = gl_FragColor * intensity;
}
