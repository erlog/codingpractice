require 'oily_png'

class Bitmap
    include Enumerable
    attr_accessor :width
    attr_accessor :height
    attr_accessor :pixelarray

	def initialize(width, height, rgb=[0,0,0])
		@bitsperpixel = 24
		@headersize = 14
		@dibheadersize = 40
		@dataoffset = @headersize + @dibheadersize
		@width = width
		@height = height
		@pixeldatasize = (@width*@height*@bitsperpixel/8)
		@filesize = @pixeldatasize + @headersize + @dibheadersize
		@padding = generatepad()
		@pixelarray = initializepixelarray(rgb)
	end

	def generateheader()
		return ["BM", @filesize, 0, 0, @dataoffset].pack("A2Vv2V")
	end

	def generatedibheader
		return [@dibheadersize, @width, @height, 1, @bitsperpixel, 0,
	  		@pixeldatasize, 2835, 2835, 0, 0].pack("Vl<2v2V2l<2V2")
	end

	def generatepad
		rowmod = (@width*@bitsperpixel/8) % 4
		padlength = 4 - rowmod
		return (padlength == 4) ?  "" : "\x0" * padlength
	end

	def initializepixelarray(rgb)
		return Array.new(@height){ Array.new(@width){rgb.dup} }
	end

	def writetofile(path)
		output = File.open(path, "w")
		output << generateheader()
		output << generatedibheader()
		for row in @pixelarray
			for rgb in row
                output << rgb.reverse.pack("CCC")
			end
			output << @padding
		end
		output.close()
	end

    def set_pixel(point, rgb)
        begin
            @pixelarray[point.y][point.x] = rgb.dup
        rescue IndexError
            pass
        end
    end

    def get_pixel(point)
        begin
            return @pixelarray[point.y][point.x]
        rescue IndexError
            pass
        end
    end

end

class TangentSpaceNormalMap
	def initialize(filename)
        bitmap = load_texture(filename)
        log("Processing normal map")
		@array = []
        for row in bitmap.pixelarray
            @array << row.map{|rgb|
                x = (rgb[0]/127.5) - 1
                y = (rgb[1]/127.5) - 1
                z = (rgb[2]/127.5) - 1
                Point.new(x, y, z).normalize!
            }
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
        log("Processing specular map")
		@array = []
        for row in bitmap.pixelarray
            #TODO: Figure out what to do here for real instead of cargo-culting
            @array << row.map{ |rgb|
                clamp((1-rgb[0]/255)*100, 1, 24)
            }
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
    bitmap = Bitmap.new(png.width, png.height)
    coord = Point.new(0, png.height - 1, 0)

    for int24 in png.pixels
        int24 = int24 >> 8
        b = int24 & 0xFF
        g = (int24 >> 8) & 0xFF
        r = (int24 >> 16) & 0xFF
        bitmap.set_pixel(coord, [r,g,b])

        coord.x += 1
        if coord.x == width
            coord.x = 0; coord.y -= 1
        end
    end
    return bitmap
end
