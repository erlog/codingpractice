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
    for(AnimatedElement anim : scheduler.get_current_elements()) {
        anim.draw(layer);
    }
}

int TimeOffset = 0;
int EndTime = 300*1000;
PFont debug_font;

PGraphics buffer;
AnimationScheduler background_elements;
AnimationScheduler text_elements;
AnimationScheduler image_elements;
AnimationScheduler john_elements;
AnimationScheduler intro_elements;

Minim minim;
AudioPlayer song;
AudioInput input;

HashMap SmootherMap;
HashMap ColorMap;
HashMap FontMap;
HashMap TextAlignMap;

void setup() {
    SmootherMap = initialize_smoothers();
    ColorMap = initialize_colors();
    FontMap = initialize_fonts();
    TextAlignMap = initialize_text_alignment();

    printArray(PFont.list());

    debug_font = createFont("Arial", 32);
    size(1280, 720, P2D);

    //Music
    minim = new Minim(this);
        //song = minim.loadFile("music.wav", 1280);
        //song.play();

    //Rendering Layers
    buffer = createGraphics(width, height);

    //Layer animation schedulers
    background_elements = parse_element_file("BackgroundElements.xml", 0);

    john_elements = parse_element_file("JohnElements.xml", 0);
    intro_elements = parse_element_file("Intro.xml", 0);
    TimeOffset -= millis();
}

void mousePressed() {
    println("(" + managed_time() + ")" + " Mouse X: " + mouseX + " Mouse Y: " + mouseY);
}

int managed_time() {
    //return (int)(frameCount * 33.33333);
    return millis() + TimeOffset;
}

void draw() {
    //render
    buffer.beginDraw();
    buffer.background(0, 0);
        render_layer(background_elements, buffer);
        render_layer(john_elements, buffer);
        //render_layer(intro_elements, buffer);
    buffer.endDraw();

    image(buffer, 0, 0);
    //blend(image_layer, 0, 0, width, height, 0, 0, width, height, SOFT_LIGHT);
    //blend(image_layer, 0, 0, width, height, 0, 0, width, height, SOFT_LIGHT);
    //blend(image_layer, 0, 0, width, height, 0, 0, width, height, SOFT_LIGHT);

    textFont(debug_font);
    text((float)managed_time()/1000, 32, 32);

    if(managed_time() >= EndTime) {
        exit();
    }
}

