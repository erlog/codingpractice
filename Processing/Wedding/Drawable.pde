interface Drawable {
    public void draw(PGraphics buffer);
}

public class DrawableText implements Drawable {
    PFont font; String display_text;

    public DrawableText(PFont font, String display_text) {
        this.font = font; this.display_text = display_text;
    }

    public void draw(PGraphics buffer) {
        buffer.textFont(font);
        color old_color = buffer.fillColor;
        buffer.fill(buffer.strokeColor);
        buffer.text(display_text, -2, 2);
        buffer.fill(old_color);
        buffer.text(display_text, 0, 0);
    }
}

public class DrawableImage implements Drawable {
    public PImage img;

    public DrawableImage(String image_path, String file_type) {
        img = loadImage(image_path, file_type);
    }

    public void draw(PGraphics buffer) {
        buffer.image(img, 0, 0);
    }
}
