require 'oily_png'

class Pixel
    attr_reader :r; attr_reader :g; attr_reader :b

    def initialize(r, g, b)
        @r, @g, @b = [r, g, b]
    end

    def self.from_int24(int24)
        b = int24 & 0xFF
        g = (int24 >> 8) & 0xFF
        r = (int24 >> 16) & 0xFF
        return Pixel.new(r, g, b)
    end

    def self.from_gray(int8)
        return Pixel.new(int8, int8, int8)
    end

    def rgb
        return [@r, @g, @b]
    end

    def to_s
        return self.rgb.to_s
    end

    def to_normal
        x, y, z = self.rgb.map{ |channel| ( (channel*2)/255.0 ) - 1 }
        return Point(x, y, z).normalize
    end

    def to_world_normal
        x, y, z = self.rgb.map { |channel| ((channel/255.0) - 0.5)*2 }
        return Point(x, y, z).normalize
    end

    def average(other)
        r = (@r + other.r)/2
        g = (@g + other.g)/2
        b = (@b + other.b)/2
        return Pixel.new(r, g, b)
    end

    def multiply(factor)
        r, g, b = self.rgb.map{ |x| (x*factor).to_i }
        return Pixel.new(r, g, b)
    end

    def -(other)
        r = @r - other.r
        g = @g - other.g
        b = @g - other.b
        return Pixel.new(r, g, b)
    end

    def +(other)
        r = @r + other.r
        g = @g + other.g
        b = @g + other.b
        return Pixel.new(r, g, b)
    end
end

class Bitmap
    attr_accessor :width
    attr_accessor :height

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
				output << pixel.rgb.reverse.pack("CCC")
			end
			output << @padding
		end
		output.close()
	end

    def bounds_check(point)
        if (point.x < 0) or (point.x >= @width) or (point.y < 0) or (point.y >= @height)
            raise IndexError, "Invalid Coordinate: #{point.to_s}"
        end
    end

    def set_pixel(point, pixel)
        @pixelarray[point.y][point.x] = pixel
    end

    def get_pixel(point)
		return @pixelarray[point.y][point.x]
    end

	def pixels
		@pixelarray.each do |row|
			row.each do |pixel|
				yield pixel
			end
		end
	end
end

class Z_Buffer
	def initialize(width, height)
		@width = width
		@height = height
		@array = Array.new(@height){ Array.new(@width){nil} }
	end

    def get_pixel(point)
		return @array[point.y][point.x]
    end

	def set_pixel(point)
        if (point.x < 0) or (point.x >= @width) or (point.y < 0) or (point.y >= @height)
            raise IndexError, "Invalid Coordinate: #{point.to_s}"
        end
		@array[point.y][point.x] = point.z
	end

    def should_draw?(point)
        z_depth = self.get_pixel(point)
        if !z_depth or (point.z > z_depth)
            self.set_pixel(point)
            return true
        end
        return false
    end
end


def load_texture(filename)
    log("Loading texture: #{filename}")
    png = ChunkyPNG::Image.from_file(filename)
    width, height = png.width, png.height
    log("Copying to bitmap.")
    bitmap = Bitmap.new(png.width, png.height)
    coord = Point(0, png.height - 1)
    png.pixels.each do |pixel|
        pixel = Pixel.from_int24(pixel >> 8)
        bitmap.set_pixel(coord, pixel)
        coord.x += 1
        if coord.x == width
            coord.x = 0
            coord.y -= 1
        end
    end
    return bitmap
end
