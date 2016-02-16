HashMap initialize_colors() {
    HashMap color_map = new HashMap();
    color_map.put("NONE", color(0));
    color_map.put("BLACK", color(0));
    color_map.put("WHITE", color(255, 255, 255));
    color_map.put("GREY", color(128));
    color_map.put("BURNT_UMBER", color(54, 20, 14));
    return color_map;
}
