def Point(x, y, z = 0)
    return PointObject.new(x, y, z)
end

def RandomPoint(max)
    return PointObject.new(rand(max), rand(max), rand(max))
end

class PointObject
    attr_reader :id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(x, y, z)
        @x = x; @y = y; @z = z
    end

    def to_s
        return [@x, @y, @z].to_s
    end

    def hash
        id.hash
    end

    def eql?(other_point)
        return self == other_point
    end

    def ==(other_point)
        return false if @x != other_point.x
        return false if @y != other_point.y
        return true
    end

    def multiply(amt)
        return PointObject.new(@x*amt, @y*amt, @z*amt)
    end

    def add(x, y, z)
        return PointObject.new(@x+x, @y+y, @z+z)
    end

    def normalize(x, y, z)
        return PointObject.new(x-@x, y-@y, z-@z)
    end

    def to_i
        @x = @x.to_i
        @y = @y.to_i
        @z = @z.to_i
        return self
    end
end

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
