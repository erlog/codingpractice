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

public class AnimationState {
    public float x; public float y;
    public float scale; public float rotation;
    public color fill_color; public color stroke_color;

    public AnimationState(float x, float y,
                            float scale, float rotation,
                            color fill_color, color stroke_color) {
        this.x = x; this.y = y;
        this.scale = scale; this.rotation = rotation;
        this.fill_color = fill_color;
        this.stroke_color = stroke_color;
    }
}

AnimationState tween(AnimationState a, AnimationState b, float amt) {
            float x = lerp(a.x, b.x, amt); float y = lerp(a.y, a.y, amt);
            float tween_scale = lerp(a.scale, b.scale, amt);
            float rotation = radians(lerp(a.rotation, b.rotation, amt));
            color fill_color = lerpColor(a.fill_color, b.fill_color, amt);
            color stroke_color = lerpColor(a.stroke_color, b.stroke_color, amt);
            return new AnimationState(x, y, tween_scale, rotation, fill_color, stroke_color);
}

interface Drawable {
    public void draw();
}

public class DrawableText implements Drawable {
    PFont font; String display_text;

    public DrawableText(PFont font, String display_text) {
        this.font = font; this.display_text = display_text;
    }

    public void draw() {
        textFont(font);
        color old_color = g.fillColor;
        fill(g.strokeColor);
        text(display_text, -2, 2);
        fill(old_color);
        text(display_text, 0, 0);
    }
}

public class DrawableImage implements Drawable {
    public PImage img;

    public DrawableImage(String image_path, String file_type) {
        img = loadImage(image_path, file_type);
    }

    public void draw() {
        image(img, 0, 0);
    }
}

public class AnimationManager{
    Drawable element;
    AnimationState in_state;
    AnimationState display_state;
    AnimationState out_state;
    float in_duration; float out_duration; float display_duration;
    float display_start_time; float display_end_time;
    boolean finished = false;
    float start_time; float finish_time;

    public AnimationManager(Drawable element,
                    AnimationState in_state,
                    AnimationState display_state,
                    AnimationState out_state,
                    float start_time,
                    float in_duration,
                    float display_duration,
                    float out_duration) {

        this.element = element;
        this.in_state = in_state;
        this.display_state = display_state;
        this.out_state = out_state;
        this.start_time = start_time*1000;
        this.in_duration = in_duration*1000;
        this.display_duration = display_duration*1000;
        this.display_start_time = this.in_duration;
        this.display_end_time = this.in_duration + this.display_duration;
        this.out_duration = out_duration*1000;
        this.finish_time = this.display_end_time + this.out_duration;
    }

    AnimationState progress() {
        float current_time = millis() - start_time;
        if(current_time < display_start_time) {
            float amt = current_time / in_duration;
            amt = constrain(amt, 0.0, 1.0);
            amt = smootherstep(amt);
            return tween(in_state, display_state, amt);
        }
        else if((current_time > display_start_time) && (current_time < display_end_time)) {
            return display_state;
        }
        else if(current_time < finish_time) {
            float amt = (current_time - display_end_time) / out_duration;
            amt = smootherstep(constrain(amt, 0.0, 1.0));
            return tween(display_state, out_state, amt);
        }
        else {
            finished = true;
            return out_state;
        }
    }

    public void draw() {
        if((millis() > start_time) && !finished) {
            pushMatrix();
            AnimationState state = progress();
            textAlign(CENTER, CENTER);
            translate(state.x, state.y);
            scale(state.scale);
            rotate(state.rotation);
            fill(state.fill_color);
            stroke(state.stroke_color);
            element.draw();
            popMatrix();
        }
    }
}

float smootherstep(float t) {
    return t = t*t*t * (t * (6.0*t - 15.0) + 10.0);
}

color set_alpha(color clr, int alpha) {
    return color(red(clr), blue(clr), green(clr), alpha);
}



//Processing code
float h_center; float v_center;

List<AnimationManager> Anims = new ArrayList<AnimationManager>();
DrawableImage my_bg;

Minim minim;
AudioPlayer song;
AudioInput input;

void setup() {
    size(1280, 720);
    h_center = width/2; v_center = height/2;

    //Colors
    color NONE = color(0, 0, 0, 0);
    color BLACK = color(0, 0, 0); color WHITE = color(255, 255, 255);
    color BURNT_UMBER = color(54, 20, 14);

    //Images
    DrawableImage myimage = new DrawableImage("photo.png", "png");
    my_bg = new DrawableImage("parchment.png", "png");


    //Fonts
    PFont great_vibes = createFont("GreatVibes-Regular", 64);
        //printArray(PFont.list());


    //Text Animations
    AnimationState in_state = new AnimationState((float)h_center, (float)v_center,
            0.01, 36.0, set_alpha(BURNT_UMBER, 0), set_alpha(BLACK, 0));
    AnimationState display_state = new AnimationState((float)h_center, (float)v_center,
            1.00, 0.0, set_alpha(BURNT_UMBER, 192), set_alpha(BLACK, 128));
    DrawableText mytext = new DrawableText(great_vibes, "お越しいただき、\n誠にありがとうございます。");
    Anims.add(new AnimationManager(mytext, in_state, display_state, in_state, 1.0, 3.0, 5.0, 2.0));
    //Anims.add(new AnimationManager(myimage, in_state, display_state, in_state, 5.0, 3.0, 1.0, 2.0));

    //Music
    minim = new Minim(this);
    song = minim.loadFile("music.wav", 1280);
        //song.play();
}

void draw() {
    my_bg.draw();

    List<AnimationManager> toremove = new ArrayList<AnimationManager>();
    for(AnimationManager anim : Anims) {
        anim.draw();
        if(anim.finished) {
            toremove.add(anim);
        }
    }
    for(AnimationManager anim : toremove) {
        Anims.remove(anim);
    }
}
