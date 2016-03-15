class Pixel
    attr_accessor :color

    def initialize(r = 0, g = 0, b = 0, int24 = nil)
        if int24
            @color = int24
        else
            @color = (b << 16) + (g << 8) + r
        end
    end

    def to_h
        return color.to_s(16).rjust(6, "0")
    end

    def self.from_int32(int32)
        #TODO: fix texture mapping code so it never returns nil
        if int32
            return Pixel.new(int24 = (int32 >> 8) )
        else
            return Pixel.new(255, 0, 255)
        end
    end

    def self.from_gray(int8)
        return Pixel.new(int8, int8, int8)
    end

    def to_int24
        return @color
    end

    def to_rgb
        r = @color & 0xFF
        g = (@color >> 8) & 0xFF
        b = (@color >> 16) & 0xFF
        return [r, g, b]
    end

    def to_s
        return self.to_rgb.to_s
    end

    def multiply(factor)
        r, g, b = self.to_rgb.map{ |x| (x * factor).to_i & 0xFF }
        return Pixel.new(r, g, b)
    end

    def from_int32(int32)
        @color = (int32 >> 8)
    end
end

class Bitmap
	def initialize(width, height, pixel = Pixel.new(0, 0, 255))
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
		for row in @pixelarray.reverse
			for pixel in row
				output << pixel.to_rgb.reverse.pack("CCC")
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

    def setpixel(point, pixel)
        bounds_check(point)
        @pixelarray[point.y][point.x] = pixel
    end

    def getpixel(point)
        bounds_check(point)
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
		@array = initializearray()
	end

	def initializearray
		return Array.new(@height){ Array.new(@width){nil} }
	end

    def getpixel(point)
		return @array[point.y][point.x]
    end

	def setpixel(point)
        if (point.x < 0) or (point.x >= @width) or (point.y < 0) or (point.y >= @height)
            return
            #raise IndexError, "Invalid Coordinate: #{point.to_s}"
        end
		@array[point.y][point.x] = point.z
	end

	def pixels
		@array.each do |row|
			row.each do |pixel|
				yield pixel
			end
		end
	end
end
