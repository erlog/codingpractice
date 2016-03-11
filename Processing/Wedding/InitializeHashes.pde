HashMap initialize_colors() {
    HashMap color_map = new HashMap();
    color_map.put("NONE", color(0));
    color_map.put("BLACK", color(0));
    color_map.put("WHITE", color(255, 255, 255));
    color_map.put("GREY", color(128));
    color_map.put("BURNT_UMBER", color(54, 20, 14));
    return color_map;
}

HashMap initialize_fonts() {
    //fonts are dynamically allocated in ElementParser
    HashMap font_map = new HashMap();
    return font_map;
}

HashMap initialize_text_alignment() {
    HashMap map = new HashMap();
    map.put("CENTER", CENTER);
    map.put("LEFT", LEFT);
    map.put("RIGHT", RIGHT);
    map.put("TOP", TOP);
    map.put("BOTTOM", BOTTOM);
    return map;
}
