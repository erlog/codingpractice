public class AnimationState {
    float x; float y;
    float scale; float rotation;
    color fill_color; color stroke_color;
    int fill_opacity; int stroke_opacity;
    float duration;

    public AnimationState(float duration, float x, float y,
                            float scale, float rotation,
                            color fill_color, int fill_opacity,
                            color stroke_color, int stroke_opacity) {

                    this.duration = duration*1000;
                    this.x = (float)x; this.y = (float)y;
                    this.x = x; this.y = y;
                    this.scale = scale; this.rotation = rotation;
                    this.fill_color = fill_color;
                    this.fill_opacity = fill_opacity;
                    this.stroke_color = stroke_color;
                    this.stroke_opacity = stroke_opacity;
    }
}
