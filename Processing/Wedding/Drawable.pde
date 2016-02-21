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
        buffer.text(display_text, 0, 0);
    }
}

public class DrawableImage implements Drawable {
    PImage img;

    public DrawableImage(String image_path, String file_type) {
        //img = loadImage(image_path, file_type);
        img = requestImage(image_path, file_type);
    }

    public void draw(PGraphics buffer) {
        int top_left_x = -1*(img.width/2);
        int top_left_y = -1*(img.height/2);
        buffer.tint(buffer.fillColor);
        buffer.image(img, top_left_x, top_left_y);
    }
}
