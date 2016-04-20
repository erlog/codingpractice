require 'oily_png'

class Pixel
    attr_reader :r; attr_reader :g; attr_reader :b

    def initialize(r, g, b)
        @r, @g, @b = [r, g, b]
    end

    def to_normal
        x = (@r/127.5) - 1
        y = (@g/127.5) - 1
        z = (@b/127.5) - 1
        return Point.new(x, y, z).normalize!
    end

    def multiply(factor)
        r = (@r*factor).round
        g = (@g*factor).round
        b = (@b*factor).round
        return Pixel.new(r, g, b)
    end
end

White = Pixel.new(255, 255, 255)

class Bitmap
    include Enumerable
    attr_accessor :width
    attr_accessor :height
    attr_accessor :pixelarray

	def initialize(width, height, pixel = Pixel.new(0, 0, 0))
		@bitsperpixel = 24
		@headersize = 14
		@dibheadersize = 40
		@dataoffset = @headersize + @dibheadersize
		@width = width
		@height = height
		@pixeldatasize = (@width*@height*@bitsperpixel/8)
		@filesize = @pixeldatasize + @headersize + @dibheadersize
		@padding = generatepad()
		@pixelarray = initializepixelarray(pixel)
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

	def initializepixelarray(pixel)
		return Array.new(@height){ Array.new(@width){pixel} }
	end

	def writetofile(path)
		output = File.open(path, "w")
		output << generateheader()
		output << generatedibheader()
		for row in @pixelarray
			for pixel in row
                output << [pixel.b,pixel.g,pixel.r].pack("CCC")
			end
			output << @padding
		end
		output.close()
	end

    def set_pixel(point, pixel)
        begin
            @pixelarray[point.y][point.x] = pixel
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
            @array << row.map(&:to_normal)
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
            @array << row.map{ |pixel|
                clamp((1-pixel.r/255)*100, 1, 24)
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
        bitmap.set_pixel(coord, Pixel.new(r,g,b))

        coord.x += 1
        if coord.x == width
            coord.x = 0; coord.y -= 1
        end
    end
    return bitmap
end
