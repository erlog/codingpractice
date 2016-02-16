public class AnimationState {
    float x; float y;
    float scale; float rotation;
    color fill_color; color stroke_color;
    float duration;

    public AnimationState(float duration, float x, float y,
                            float scale, float rotation,
                            color fill_color, color stroke_color) {

                    this.duration = duration*1000;
                    this.x = (float)x; this.y = (float)y;
                    this.x = x; this.y = y;
                    this.scale = scale; this.rotation = rotation;
                    this.fill_color = fill_color;
                    this.stroke_color = stroke_color;
    }
}
