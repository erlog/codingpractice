directory_path = ARGV[0]
valid_extensions = ["jpg", "png", "tif", "gif"]

item_duration = 6
start_time = 1
item_string = '<element type="image">
    <start_time>%s</start_time>
    <file_path>%s</file_path>
    <in_state>
        <duration>2</duration>
        <x_pos>0</x_pos> <y_pos>0</y_pos>
        <scale>0</scale> <rotation>0</rotation>
        <fill_color>WHITE</fill_color> <fill_opacity>0</fill_opacity>
        <stroke_color>NONE</stroke_color> <stroke_opacity>0</stroke_opacity>
    </in_state>
    <display_state>
        <duration>2</duration>
        <x_pos>0</x_pos> <y_pos>0</y_pos>
        <scale>0</scale> <rotation>0</rotation>
        <fill_color>WHITE</fill_color> <fill_opacity>255</fill_opacity>
        <stroke_color>NONE</stroke_color> <stroke_opacity>0</stroke_opacity>
    </display_state>
    <out_state>
        <duration>2</duration>
        <x_pos>0</x_pos> <y_pos>0</y_pos>
        <scale>0</scale> <rotation>0</rotation>
        <fill_color>WHITE</fill_color> <fill_opacity>0</fill_opacity>
        <stroke_color>NONE</stroke_color> <stroke_opacity>0</stroke_opacity>
    </out_state>
</element>

'

output_file = open("default_slideshow.xml", "w")

Dir.entries(directory_path).each do |file|
    if File.file?(File.join(directory_path, file))
        if valid_extensions.include?(file[-3..-1].downcase)
            output_file.write(item_string % [start_time, file])
            start_time += item_duration
        end
    end
end

output_file.close()
