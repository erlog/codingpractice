require 'matrix'

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
        @x = x; @y = y; @z = z
    end

    def to_s
        return [@x, @y, @z].to_s
    end

    def to_i
        return PointObject.new(@x.to_i, @y.to_i, @z.to_i)
    end

    def rotate_x(cos, sin)
        matrix = Matrix[    [1, 0, 0, 0],
                            [0, cos, sin*-1, 0],
                            [0, sin, cos, 0],
                            [0, 0, 0, 1] ]

        position = Matrix.column_vector([@x, @y, @z, 1])
        array = (matrix * position).column(0).to_a
        return Point(array[0], array[1], array[2])
    end

    def rotate_y(cos, sin)
        matrix = Matrix[    [cos, 0, sin, 0],
                            [0, 1, 0, 0],
                            [sin*-1, 0, cos, 0],
                            [0, 0, 0, 1] ]

        position = Matrix.column_vector([@x, @y, @z, 1])
        array = (matrix * position).column(0).to_a
        return Point(array[0], array[1], array[2])
    end

    def rotate_z(cos, sin)
        matrix = Matrix[    [cos, sin*-1, 0, 0],
                            [sin, cos, 0, 0],
                            [0, 0, 1, 0],
                            [0, 0, 0, 1] ]

        position = Matrix.column_vector([@x, @y, @z, 1])
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
        return true
    end

    def cross_product(other)
        x = (@y*other.z) - (@z*other.y)
        y = (@z*other.x) - (@x*other.z)
        z = (@x*other.y) - (@y*other.x)
        return PointObject.new(x, y, z)
    end

    def scalar_product(other)
        return (@x*other.x) + (@y*other.y) + (@z*other.z)
    end

    def to_screen(center)
        return (center - (self * center)).to_i
    end

    def project(distance)
        x = @x / (1 - @z/distance)
        y = @y / (1 - @z/distance)
        z = @z / (1 - @z/distance)
        return PointObject.new(x, y, z)
    end

    def normalize
        #I'm not sure I trust this
        factor = Math.sqrt( (@x**2).abs + (@y**2).abs + (@z**2).abs )
        return self / PointObject.new(factor, factor, factor)
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
