
def Point(x, y, z = 1)
    return PointObject.new(x, y, z)
end

class PointObject
    attr_reader :id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(x, y, z)
        @x = x; @y = y; @z = z
        if @x == Float::NAN
            raise ArgumentError
        end
    end

    def self.from_array(xyz)
        @x, @y, @z = xyz.to_a
        return PointObject.new(@x, @y, @z)
    end

    def to_s
        return [@x, @y, @z].to_s
    end

    def to_i
        return PointObject.new(@x.to_i, @y.to_i, @z.to_i)
    end

    def to_i!
        @x = @x.to_i; @y = @y.to_i; @z = @z.to_i
        return self
    end

    def u
        return @x
    end

    def v
        return @y
    end

    def xyz
        return [@x, @y, @z]
    end

    def xy_negative?
        return true if @x < 0
        return true if @y < 0
        return false
    end

    def apply_matrix!(matrix)
        #matrix math unrolled for performance gains
        x = (matrix[0][0] * @x) + (matrix[0][1] * @y) + (matrix[0][2] * @z) + matrix[0][3]
        y = (matrix[1][0] * @x) + (matrix[1][1] * @y) + (matrix[1][2] * @z) + matrix[1][3]
        z = (matrix[2][0] * @x) + (matrix[2][1] * @y) + (matrix[2][2] * @z) + matrix[2][3]
        d = (matrix[3][0] * @x) + (matrix[3][1] * @y) + (matrix[3][2] * @z) + matrix[3][3]
        @x = x/d; @y = y/d; @z = z/d    #parallel assignments are slower
        return self
    end

    def apply_tangent_matrix!(tbn)
        #matrix math unrolled for performance gains
        tangent, bitangent, normal = tbn
        x = (tangent.x * @x) + (bitangent.x * @y) + (normal.x * @z)
        y = (tangent.y * @x) + (bitangent.y * @y) + (normal.y * @z)
        z = (tangent.z * @x) + (bitangent.z * @y) + (normal.z * @z)
        @x = x; @y = y; @z = z    #parallel assignments are slower
        return self
    end

    def hash
        id.hash
    end

    def eql?(other)
        return self == other
    end

    def ==(other)
        return false if @x != other.x
        return false if @y != other.y
        return false if @z != other.z
        return true
    end

    def cross_product(other)
        x = (@y*other.z) - (@z*other.y)
        y = (@z*other.x) - (@x*other.z)
        z = (@x*other.y) - (@y*other.x)
        return PointObject.new(x, y, z)
    end

    def scale_by_factor!(factor)
        @x = @x * factor
        @y = @y * factor
        @z = @z * factor
        return self
    end

    def scale_by_factor(factor)
        return PointObject.new(@x*factor, @y*factor, @z*factor)
    end

    def scalar_product(other)
        return (@x*other.x) + (@y*other.y) + (@z*other.z)
    end

    def to_screen(center)
        #unrolled for performance
        x = (center.x + (@x * center.x)).to_i
        y = (center.y + (@y * center.y)).to_i
        z = (center.z + (@z * center.z)).to_i
        return Point(x, y, z)
    end

    def to_texture!(texture_size)
        @x = (@x * texture_size.x).to_i
        @y = (@y * texture_size.y).to_i
        return self
    end

    def to_screen!(center)
        #unrolled for performance
        @x = (center.x + (@x * center.x)).to_i
        @y = (center.y + (@y * center.y)).to_i
        @z = (center.z + (@z * center.z)).to_i
        return self
    end

    def compute_reflection(light_direction)
        reflection = self.scale_by_factor(-2*self.scalar_product(light_direction))
        reflection += light_direction
        return reflection.normalize
    end

    def normalize
        factor = Math.sqrt( (@x**2) + (@y**2) + (@z**2) )
        return self.scale_by_factor(1.0/factor)
    end

    def normalize!
        length = Math.sqrt( (@x**2) + (@y**2) + (@z**2) )
        @x = @x/length
        @y = @y/length
        @z = @z/length
        return self
    end

    def rgb
        point = self.normalize
        r = (point.x*127) + 128
        g = (point.y*127) + 128
        b = (point.z*127) + 128
        return Pixel.new(r, g, b)
    end

    def +(other)
        return PointObject.new(@x+other.x, @y+other.y, @z+other.z)
    end

    def -(other)
        return PointObject.new(@x-other.x, @y-other.y, @z-other.z)
    end

    def /(other)
        return PointObject.new(@x/other.x, @y/other.y, @z/other.z)
    end

    def *(other)
        return PointObject.new(@x*other.x, @y*other.y, @z*other.z)
    end

end

