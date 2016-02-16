AnimationState tween(AnimationState a, AnimationState b, float amt) {
            float x = lerp(a.x, b.x, amt); float y = lerp(a.y, a.y, amt);
            float tween_scale = lerp(a.scale, b.scale, amt);
            float rotation = radians(lerp(a.rotation, b.rotation, amt));
            color fill_color = lerpColor(a.fill_color, b.fill_color, amt);
            color stroke_color = lerpColor(a.stroke_color, b.stroke_color, amt);
            return new AnimationState(0.0, x, y, tween_scale, rotation, fill_color, stroke_color);
}

float smootherstep(float t) {
    return t = t*t*t * (t * (6.0*t - 15.0) + 10.0);
}

color set_alpha(color clr, int alpha) {
    return color(red(clr), blue(clr), green(clr), alpha);
}

int managed_time() {
    return millis() + TimeOffset;
}
