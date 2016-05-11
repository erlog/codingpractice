varying vec2 texture_coordinate; 
uniform sampler2D diffuse;

void main() { 
    // Sampling The Texture And Passing It To The Frame Buffer
    gl_FragColor = texture2D(diffuse, texture_coordinate);
}
