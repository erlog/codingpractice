interface Drawable {
    public void draw(PGraphics buffer, AnimationState state);
}

public class DrawableText implements Drawable {
    PFont font;
    String display_text;
    int font_size;
    int align_horizontal;
    int align_vertical;

    public DrawableText(PFont font, String display_text, int font_size, int align_horizontal, int align_vertical) {
        this.font = font;
        this.display_text = display_text;
        this.font_size = font_size;
        this.align_horizontal = align_horizontal;
        this.align_vertical = align_vertical;

    }

    public void draw(PGraphics buffer, AnimationState state) {
        buffer.textAlign(CENTER, CENTER);
        buffer.translate(state.x, state.y);
        buffer.scale(state.scale);
        buffer.rotate(state.rotation);
        buffer.textFont(font);
        buffer.textAlign(align_horizontal, align_vertical);
        buffer.textSize(font_size);
        buffer.fill(state.stroke_color, state.stroke_opacity);
        buffer.text(display_text, -2, 0);
        buffer.text(display_text, 2, 0);
        buffer.text(display_text, 0, -2);
        buffer.text(display_text, 0, 2);
        buffer.fill(state.fill_color, state.fill_opacity);
        buffer.text(display_text, 0, 0);
    }
}

public class DrawableImage implements Drawable {
    PImage img;

    public DrawableImage(String image_path, String file_type) {
        img = loadImage(image_path, file_type);
        //img = requestImage(image_path, file_type);
    }

    public void draw(PGraphics buffer, AnimationState state) {
        buffer.translate(state.x, state.y);
        buffer.scale(state.scale);
        buffer.rotate(state.rotation);
        buffer.tint(state.fill_color, state.fill_opacity);
        buffer.imageMode(CENTER);
        buffer.image(img, 0, 0);
    }
}
