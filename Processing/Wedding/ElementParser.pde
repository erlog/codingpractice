AnimationScheduler parse_element_file(String file_path) {
    AnimationScheduler scheduler = new AnimationScheduler();

    XML xml = loadXML(file_path);
    XML[] elements = xml.getChildren("element");

    for(int i = 0; i < elements.length; i++) {

        String type = elements[i].getString("type");
        if(type.equals("text")) {
            scheduler.add(parse_text_element(elements[i]));
        }
        else if(type.equals("image")) {
            scheduler.add(parse_image_element(elements[i]));
        }
    }

    return scheduler;
}

AnimatedElement parse_text_element(XML xml_element) {
    String text_string = xml_element.getChildren("string")[0].getContent();
    String font_name = xml_element.getChildren("font")[0].getContent();
    int font_size = xml_element.getChildren("font_size")[0].getIntContent();
    float start_time  = xml_element.getChildren("start_time")[0].getFloatContent();

    PFont font = createFont(font_name, font_size);
    DrawableText text = new DrawableText(font, text_string);
    AnimationState in_state = parse_animation_state(xml_element.getChildren("in_state")[0]);
    AnimationState display_state = parse_animation_state(xml_element.getChildren("display_state")[0]);
    AnimationState out_state = parse_animation_state(xml_element.getChildren("out_state")[0]);

    return new AnimatedElement(text, in_state, display_state, out_state, start_time);
}

AnimatedElement parse_image_element(XML xml_element) {
    String file_path = xml_element.getChildren("file_path")[0].getContent();
    String file_type = file_path.substring(file_path.length()-3, file_path.length());
    println(file_type);
    float start_time  = xml_element.getChildren("start_time")[0].getFloatContent();

    DrawableImage image = new DrawableImage(file_path, file_type);
    AnimationState in_state = parse_animation_state(xml_element.getChildren("in_state")[0]);
    AnimationState display_state = parse_animation_state(xml_element.getChildren("display_state")[0]);
    AnimationState out_state = parse_animation_state(xml_element.getChildren("out_state")[0]);

    return new AnimatedElement(image, in_state, display_state, out_state, start_time);
}

AnimationState parse_animation_state(XML xml_element) {
    float duration = xml_element.getChildren("duration")[0].getFloatContent();
    float x = xml_element.getChildren("x_pos")[0].getFloatContent();
    float y = xml_element.getChildren("y_pos")[0].getFloatContent();
    float scale = xml_element.getChildren("scale")[0].getFloatContent();
    float rotation = xml_element.getChildren("rotation")[0].getFloatContent();
    color fill_color = (color)ColorMap.get(xml_element.getChildren("fill_color")[0].getContent());
    color stroke_color = (color)ColorMap.get(xml_element.getChildren("stroke_color")[0].getContent());
    fill_color = set_alpha(fill_color, xml_element.getChildren("fill_opacity")[0].getIntContent());
    stroke_color = set_alpha(stroke_color, xml_element.getChildren("stroke_opacity")[0].getIntContent());
    return new AnimationState(duration, x, y, scale, rotation, fill_color, stroke_color);
}
