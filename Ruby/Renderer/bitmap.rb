require 'oily_png'

class TangentSpaceNormalMap
	def initialize(filename)
        bitmap = load_texture(filename)
        width,height = bitmap.dimensions
        log("Processing normal map")
		@array = []
        point = Point.new(0, 0, 0);
        x = 0; y = 0;
        while y < height;
            point.y = y; row = []
            while x < width;
                point.x = x;
                rgb = bitmap.get_pixel(point);
                point_x = (rgb[0]/127.5) - 1
                point_y = (rgb[1]/127.5) - 1
                point_z = (rgb[2]/127.5) - 1
                row << Point.new(point_x, point_y, point_z).normalize!
                x += 1;
            end
            x = 0; y += 1;
            @array << row;
        end
	end

    def get_normal(point)
        begin
            return @array[point.y][point.x]
        rescue IndexError
            pass
        end
    end
end

class SpecularMap
	def initialize(filename)
        bitmap = load_texture(filename)
        width,height = bitmap.dimensions
        log("Processing specular map")
		@array = []
        point = Point.new(0, 0, 0);
        x = 0; y = 0;
        while y < height;
            point.y = y; row = []
            while x < width;
                point.x = x;
                rgb = bitmap.get_pixel(point);
            #TODO: Figure out what to do here for real instead of cargo-culting
                row << clamp((1-rgb[0]/255)*100, 1, 24)
                x += 1;
            end
            x = 0; y += 1;
            @array << row;
        end
	end

    def get_specular(point)
        begin
            return @array[point.y][point.x]
        rescue IndexError
            pass
        end
    end
end


def load_texture(filename)
    log("Loading texture: #{filename}")
    png = ChunkyPNG::Image.from_file(filename)
    width, height = png.width, png.height
    bitmap = Bitmap.new(png.width, png.height, Black)
    coord = Point.new(0, png.height - 1, 0)

    for int32 in png.pixels
        int24 = int32 >> 8;
        bitmap.set_pixel(coord, int24)

        coord.x += 1
        if coord.x == width
            coord.x = 0; coord.y -= 1
        end
    end
    return bitmap
end
