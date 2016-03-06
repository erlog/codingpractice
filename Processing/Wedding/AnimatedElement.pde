//a package of a drawable element, animation states, and timing information
//manages tweening and drawing

public class AnimatedElement {
    Drawable element;
    Smoother smoother;
    boolean finished = false;
    float start_time; float finish_time;
    AnimationState in_state;
    AnimationState display_state_in;
    AnimationState display_state_out;
    AnimationState out_state;
    float display_start_time; float display_end_time;

    public AnimatedElement(Drawable element,
                    Smoother smoother,
                    AnimationState in_state,
                    AnimationState display_state_in,
                    AnimationState display_state_out,
                    AnimationState out_state,
                    float start_time) {

        this.element = element;
        this.smoother = smoother;
        this.in_state = in_state;
        this.display_state_in = display_state_in;
        this.display_state_out = display_state_out;
        this.out_state = out_state;
        this.start_time = start_time * 1000;
        this.display_start_time = in_state.duration;
        this.display_end_time = display_start_time + display_state_in.duration;
        this.finish_time = display_end_time + out_state.duration;
    }

    boolean is_active() {
        float time = managed_time();
        float end_time = start_time + finish_time;
        if(time >= end_time) {
            finished = true;
            return false;
        }
        else {
            return true;
        }
    }


    AnimationState progress() {
        float current_time = managed_time() - start_time;
        if(current_time < display_start_time) {
            float amt = current_time / in_state.duration;
            amt = smoother.smooth(constrain(amt, 0.0, 1.0));
            return tween(in_state, display_state_in, amt);
        }
        else if((current_time > display_start_time) && (current_time < display_end_time)) {
            float amt = (current_time - display_start_time) / display_state_in.duration;
            amt = smoother.smooth(constrain(amt, 0.0, 1.0));
            return tween(display_state_in, display_state_out, amt);
        }
        else {
            float amt = (current_time - display_end_time) / out_state.duration;
            amt = smoother.smooth(constrain(amt, 0.0, 1.0));
            return tween(display_state_out, out_state, amt);
        }
    }

    public void draw(PGraphics buffer) {
        if(is_active()) {
            AnimationState state = progress();
            buffer.pushMatrix();
            element.draw(buffer, state);
            buffer.popMatrix();
        }
    }
}

AnimationState tween(AnimationState a, AnimationState b, float amt) {
            float x = lerp(a.x, b.x, amt); float y = lerp(a.y, b.y, amt);
            float tween_scale = lerp(a.scale, b.scale, amt);
            float rotation = radians(lerp(a.rotation, b.rotation, amt));
            color fill_color = lerpColor(a.fill_color, b.fill_color, amt);
            int fill_opacity = lerpColor(a.fill_opacity, b.fill_opacity, amt);
            color stroke_color = lerpColor(a.stroke_color, b.stroke_color, amt);
            int stroke_opacity = lerpColor(a.stroke_opacity, b.stroke_opacity, amt);
            return new AnimationState(0, x, y, tween_scale, rotation,
                        fill_color, fill_opacity, stroke_color, stroke_opacity);
}
