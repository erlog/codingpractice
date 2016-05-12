//Inputs
varying vec2 texture_coordinate;
varying vec3 local_normal;
varying vec3 local_tangent;

//Textures
uniform sampler2D diffuse;
uniform sampler2D normal;
uniform sampler2D specular;

//Variables
vec3 light_direction;
vec3 camera_direction;
vec3 local_bitangent;
vec3 mapped_normal;
vec4 color;

void main() {
    //compute mapped normal in model space
    color = texture2D(normal, texture_coordinate);
    vec3 tangent_normal = normalize(color.rgb*2.0 - 1.0);
    vec3 local_bitangent = normalize(cross(local_normal, local_tangent));
    mapped_normal.x = (local_tangent.x * tangent_normal.x) +
        (local_bitangent.x * tangent_normal.y) +
        (local_normal.x * tangent_normal.z);
    mapped_normal.y = (local_tangent.y * tangent_normal.x) +
        (local_bitangent.y * tangent_normal.y) +
        (local_normal.y * tangent_normal.z);
    mapped_normal.z = (local_tangent.z * tangent_normal.x) +
        (local_bitangent.z * tangent_normal.y) +
        (local_normal.z * tangent_normal.z);

    //convert to world space
    mapped_normal = gl_NormalMatrix * mapped_normal;
    normalize(mapped_normal);

    //compute diffuse intensity
    light_direction = vec3(0.0, 0.0, 1.0);
    float diffuse_intensity = clamp(dot(light_direction, mapped_normal), 0.0, 1.0);

    //compute specular intensity
    camera_direction = vec3(0.0, 0.0, 1.0);
    float factor = diffuse_intensity*-2.0;
    vec3 reflection_vector = (mapped_normal * factor) + mapped_normal;
    normalize(reflection_vector);
    color = texture2D(specular, texture_coordinate);
    float power = color.r*100.0;
    float reflectivity = clamp(dot(camera_direction, reflection_vector)*-1.0, 0.0, 1.0);
    reflectivity = pow(reflectivity, power);


    //factor = 0.05 + 0.6*reflectivity + 0.75*diffuse_intensity;
    float intensity = 0.05 + 0.6*reflectivity + 0.75*diffuse_intensity;
    gl_FragColor = texture2D(diffuse, texture_coordinate) * intensity;
    vec3 t = local_tangent;
    gl_FragColor = vec4(t.x, t.y, t.z, 1.0);
}
