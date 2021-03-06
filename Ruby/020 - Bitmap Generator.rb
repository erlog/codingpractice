class Pixel
	def initialize
		@rgb = "000000"
	end
	
	def rgb=(s)
		#fix endianness
		@rgb = s.reverse
	end
	
	def tobitmap
		return [@rgb].pack("H6")
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
				output << pixel.tobitmap()
			end
			output << @padding
		end
		output.close()
	end
	
	def setpixel(x, y, rgbvalue)
		@pixelarray[y][x].rgb = rgbvalue
	end

	def rawpixels
		@pixelarray.each do |row|
			row.each do |pixel|
				yield pixel
			end
		end
	end
end


mybmp = Bitmap.new(16, 16)
mybmp.setpixel(15, 15, "000000")
mybmp.writetofile("test.bmp")


mybmp.rawpixels{|pixel| pixel.rgb=rand(1<<24).to_s(16)}
mybmp.writetofile("test.bmp")
