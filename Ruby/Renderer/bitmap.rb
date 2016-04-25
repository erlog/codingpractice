require 'oily_png'

class TangentSpaceNormalMap
	def initialize(bitmap)
        width,height = bitmap.dimensions
        log("Processing normal map")
		@array = []
        point = Point.new(0, 0, 0);
        x = 0; y = 0;
        while y < height;
            point.y = y; row = []
            while x < width;
                point.x = x;
                color = bitmap.get_pixel(point);
                b = color & 255; color = color >> 8;
                g = color & 255; color = color >> 8;
                r = color & 255;
                point_x = (r/127.5) - 1
                point_y = (g/127.5) - 1
                point_z = (b/127.5) - 1
                normal = Point.new(point_x, point_y, point_z).normalize!
                row << normal
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
	def initialize(bitmap)
        width,height = bitmap.dimensions
        log("Processing specular map")
		@array = []
        point = Point.new(0, 0, 0);
        x = 0; y = 0;
        while y < height;
            point.y = y; row = []
            while x < width;
                point.x = x;
                color = bitmap.get_pixel(point) & 255;
            #TODO: Figure out what to do here for real instead of cargo-culting
                row << clamp((1-color/255)*100, 1, 24)
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
    bitmap = Bitmap.new(png.width, png.height, [0,0,0])
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
