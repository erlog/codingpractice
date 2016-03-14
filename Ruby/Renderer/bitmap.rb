class Pixel
    attr_reader :rgb

	def initialize
		@rgb = ["000000"].pack("H6")
	end

	def rgb=(hexstring)
		@rgb = [hexstring.reverse].pack("H6")
	end
end

class Bitmap
	def initialize(width, height)
		@bitsperpixel = 24
		@headersize = 14
		@dibheadersize = 40
		@dataoffset = @headersize + @dibheadersize
		@width = width
		@height = height
		@pixeldatasize = (@width*@height*@bitsperpixel/8)
		@filesize = @pixeldatasize + @headersize + @dibheadersize
		@padding = generatepad()
		@pixelarray = initializepixelarray()
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

	def initializepixelarray
		return Array.new(@height){ Array.new(@width){Pixel.new()} }
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

	def setpixel(point, rgbvalue)
        if (point.x < 0) or (point.x >= @width) or (point.y < 0) or (point.y >= @height)
            return
            #raise IndexError, "Invalid Coordinate: #{point.to_s}"
        end
		@pixelarray[point.y][point.x].rgb = rgbvalue
	end

    def setpixels(points, rgbvalue)
        points.each do |point| self.setpixel(point, rgbvalue) end
    end

	def pixels
		@pixelarray.each do |row|
			row.each do |pixel|
				yield pixel
			end
		end
	end
end
