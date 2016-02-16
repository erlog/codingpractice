public class AnimatedElement {
    Drawable element;
    boolean finished = false;
    float start_time; float finish_time;
    AnimationState in_state;
    AnimationState display_state;
    AnimationState out_state;
    float display_start_time; float display_end_time;

    public AnimatedElement(Drawable element,
                    AnimationState in_state,
                    AnimationState display_state,
                    AnimationState out_state,
                    float start_time) {

        this.element = element;
        this.in_state = in_state;
        this.display_state = display_state;
        this.out_state = out_state;
        this.start_time = start_time * 1000;
        this.display_start_time = in_state.duration;
        this.display_end_time = display_start_time + display_state.duration;
        this.finish_time = display_end_time + out_state.duration;
    }

    AnimationState progress() {
        float current_time = managed_time() - start_time;
        if(current_time < display_start_time) {
            float amt = current_time / in_state.duration;
            amt = constrain(amt, 0.0, 1.0);
            amt = smootherstep(amt);
            return tween(in_state, display_state, amt);
        }
        else if((current_time > display_start_time) && (current_time < display_end_time)) {
            return display_state;
        }
        else if(current_time < finish_time) {
            float amt = (current_time - display_end_time) / out_state.duration;
            amt = smootherstep(constrain(amt, 0.0, 1.0));
            return tween(display_state, out_state, amt);
        }
        else {
            finished = true;
            return out_state;
        }
    }

    public void draw(PGraphics buffer) {
        if((managed_time() > start_time) && !finished) {
            buffer.pushMatrix();
            AnimationState state = progress();
            buffer.textAlign(CENTER, CENTER);
            buffer.translate(state.x, state.y);
            buffer.scale(state.scale);
            buffer.rotate(state.rotation);
            buffer.fill(state.fill_color);
            buffer.stroke(state.stroke_color);
            element.draw(buffer);
            buffer.popMatrix();
        }
    }
}
