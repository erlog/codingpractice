import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.function.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

void render_layer(AnimationScheduler scheduler, PGraphics layer) {
    layer.beginDraw();
    layer.background(0, 0);
    for(AnimatedElement anim : scheduler.get_current_elements()) {
        anim.draw(layer);
    }
    layer.endDraw();
}

int TimeOffset = 0;

PGraphics background_layer;
AnimationScheduler background_elements;

PGraphics text_layer;
AnimationScheduler text_elements;

PGraphics image_layer;
AnimationScheduler image_elements;

Minim minim;
AudioPlayer song;
AudioInput input;

//Colors
HashMap ColorMap = initialize_colors();

void setup() {
    size(1280, 720);
    //printArray(PFont.list());

    //Music
    minim = new Minim(this);
        //song = minim.loadFile("music.wav", 1280);
        //song.play();

    //Rendering Layers
    background_layer = createGraphics(width, height);
    text_layer = createGraphics(width, height);
    image_layer = createGraphics(width, height);

    //Layer animation schedulers
    background_elements = parse_element_file("BackgroundElements.xml");
    image_elements = parse_element_file("ImageElements.xml");
    text_elements = parse_element_file("TextElements.xml");
    TimeOffset -= millis();
}

void draw() {
    //render
    render_layer(background_elements, background_layer);
    render_layer(image_elements, image_layer);
    render_layer(text_elements, text_layer);

    //composite
    background(128);
    image(background_layer, 0, 0);
    image(image_layer, 0, 0);
    //image(text_layer, 0, 0);
    blend(text_layer, 0, 0, width, height, 0, 0, width, height, SOFT_LIGHT);
}

