begin
    require 'rubygems'
    require_relative 'matrix_math'
    require_relative 'utilities'
    require_relative 'wavefront'

    Start_Time = Time.now

    def ruby_update()
        puts("hello");
        #objects.each do |object|
        #    render_model(object[0], view_matrix, normal_matrix,
        #        camera_direction, light_direction,
        #        bitmap, z_buffer, object[1], object[2], object[3])
        #end
    end
rescue Exception => e
    puts e
    puts "---"
    puts e.backtrace
end
