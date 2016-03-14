class Pixel
    attr_reader :rgb

	def initialize(colorhexstring)
		@rgb = [colorhexstring].pack("H6")
	end

	def rgb=(hexstring)
        #this is pretty lol and was the source of a dumb bug
        hexstring = hexstring.chars.each_slice(2).to_a.reverse.join
		@rgb = [hexstring].pack("H6")
	end

    def int=(value)
        @rgb = value
    end
end

class Bitmap
	def initialize(width, height, color = "FF0000")
		@bitsperpixel = 24
		@headersize = 14
		@dibheadersize = 40
		@dataoffset = @headersize + @dibheadersize
		@width = width
		@height = height
		@pixeldatasize = (@width*@height*@bitsperpixel/8)
		@filesize = @pixeldatasize + @headersize + @dibheadersize
		@padding = generatepad()
		@pixelarray = initializepixelarray(color)
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

	def initializepixelarray(color)
		return Array.new(@height){ Array.new(@width){Pixel.new(color)} }
	end

	def writetofile(path)
		output = File.open(path, "w")
		output << generateheader()
		output << generatedibheader()
		for row in @pixelarray.reverse
			for pixel in row
				output << pixel.rgb
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

    def getpixel(point)
        bounds_check(point)
		return @pixelarray[point.y][point.x]
    end

    def setpixelraw(point, integer)
        bounds_check(point)
        @pixelarray[point.y][point.x].int = integer
    end

	def setpixel(point, rgbvalue)
        bounds_check(point)
		@pixelarray[point.y][point.x].rgb = rgbvalue
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
