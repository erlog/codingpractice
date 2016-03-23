
def Point(x, y, z = 1)
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
        @x = x.to_f; @y = y.to_f; @z = z.to_f
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

    def xy_to_i
        return PointObject.new(@x.to_i, @y.to_i, @z)
    end

    def to_i
        return PointObject.new(@x.to_i, @y.to_i, @z.to_i)
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

    def apply_matrix(matrix)
        position = Matrix.column_vector([@x, @y, @z, 1])
        array = (matrix * position).column(0).to_a
        return Point(array[0]/array[3], array[1]/array[3], array[2]/array[3])
    end

    def apply_tangent_matrix(matrix)
        position = Matrix.column_vector([@x, @y, @z])
        array = (matrix * position).column(0).to_a
        return Point(array[0], array[1], array[2])
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

    def scale_by_factor(factor)
        return PointObject.new(@x*factor, @y*factor, @z*factor)
    end

    def scalar_product(other)
        return (@x*other.x) + (@y*other.y) + (@z*other.z)
    end

    def to_screen(center)
        return (center + (self * center)).xy_to_i
    end

    def compute_reflection(light_direction)
        reflection = self.scale_by_factor(-2*self.scalar_product(light_direction))
        reflection += light_direction
        return reflection.normalize
    end

    def normalize
        factor = Math.sqrt( (@x**2) + (@y**2) + (@z**2) )
        return self / PointObject.new(factor, factor, factor)
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

def bounds_check(point, maximum_point)
    if (point.x < 0)
        return false
    elsif (point.x >= maximum_point.x)
        return false
    elsif (point.y < 0)
        return false
    elsif (point.y >= maximum_point.y)
        return false
    end

    return true
end
