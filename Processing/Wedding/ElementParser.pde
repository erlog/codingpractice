//Parser for the XML files that define elements

AnimationScheduler parse_element_file(String file_path, float time_offset) {
    AnimationScheduler scheduler = new AnimationScheduler();

    XML xml = loadXML(file_path);
    XML[] elements = xml.getChildren("element");

    for(int i = 0; i < elements.length; i++) {

        String type = elements[i].getString("type");
        if(type.equals("text")) {
            scheduler.add(parse_text_element(elements[i], time_offset));
        }
        else if(type.equals("image")) {
            scheduler.add(parse_image_element(elements[i], time_offset));
        }
    }

    return scheduler;
}

AnimatedElement parse_text_element(XML xml_element, float time_offset) {
    String text_string = xml_element.getChildren("string")[0].getContent();
    text_string = text_string.replace("\\n", "\n");
    println("Parsing Text: " + text_string);
    int horizontal_alignment = (int)TextAlignMap.get(xml_element.getChildren("align_horizontal")[0].getContent());
    int vertical_alignment = (int)TextAlignMap.get(xml_element.getChildren("align_vertical")[0].getContent());
    String font_name = xml_element.getChildren("font")[0].getContent();
    PFont font = (PFont)FontMap.get(font_name);
    if(font == null) {
        FontMap.put(font_name, createFont(font_name, 32));
        font = (PFont)FontMap.get(font_name);
    }

    int font_size = xml_element.getChildren("font_size")[0].getIntContent();
    float start_time  = xml_element.getChildren("start_time")[0].getFloatContent();
    start_time += time_offset;

    DrawableText text = new DrawableText(font, text_string, font_size, horizontal_alignment, vertical_alignment);
    Smoother smoother  = (Smoother)SmootherMap.get(xml_element.getChildren("smoother")[0].getContent());
    AnimationState in_state = parse_animation_state(xml_element.getChildren("in_state")[0]);
    AnimationState display_state_in = parse_animation_state(xml_element.getChildren("display_state_in")[0]);
    AnimationState display_state_out = parse_animation_state(xml_element.getChildren("display_state_out")[0]);
    AnimationState out_state = parse_animation_state(xml_element.getChildren("out_state")[0]);

    return new AnimatedElement(text, smoother, in_state, display_state_in, display_state_out, out_state, start_time);
}

AnimatedElement parse_image_element(XML xml_element, float time_offset) {
    String file_path = xml_element.getChildren("file_path")[0].getContent();
    println("Parsing Image: " + file_path);
    String file_type = file_path.substring(file_path.length()-3, file_path.length());
    float start_time  = xml_element.getChildren("start_time")[0].getFloatContent();
    start_time += time_offset;

    DrawableImage image = new DrawableImage(file_path, file_type);
    Smoother smoother  = (Smoother)SmootherMap.get(xml_element.getChildren("smoother")[0].getContent());
    AnimationState in_state = parse_animation_state(xml_element.getChildren("in_state")[0]);
    AnimationState display_state_in = parse_animation_state(xml_element.getChildren("display_state_in")[0]);
    AnimationState display_state_out = parse_animation_state(xml_element.getChildren("display_state_out")[0]);
    AnimationState out_state = parse_animation_state(xml_element.getChildren("out_state")[0]);

    return new AnimatedElement(image, smoother, in_state, display_state_in, display_state_out,  out_state, start_time);
}

AnimationState parse_animation_state(XML xml_element) {
    float duration = xml_element.getChildren("duration")[0].getFloatContent();
    float x = xml_element.getChildren("x_pos")[0].getFloatContent();
    float y = xml_element.getChildren("y_pos")[0].getFloatContent();
    float scale = xml_element.getChildren("scale")[0].getFloatContent();
    float rotation = xml_element.getChildren("rotation")[0].getFloatContent();
    color fill_color = (color)ColorMap.get(xml_element.getChildren("fill_color")[0].getContent());
    color stroke_color = (color)ColorMap.get(xml_element.getChildren("stroke_color")[0].getContent());
    int fill_opacity = xml_element.getChildren("fill_opacity")[0].getIntContent();
    int stroke_opacity = xml_element.getChildren("stroke_opacity")[0].getIntContent();
    return new AnimationState(duration, x, y, scale, rotation,
                        fill_color, fill_opacity, stroke_color, stroke_opacity);
}
