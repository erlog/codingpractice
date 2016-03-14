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

    def to_i
        return PointObject.new(@x.to_i, @y.to_i, @z.to_i)
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

    def normalize
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
