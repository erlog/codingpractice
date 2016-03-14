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

    def normalize(x, y, z)
        return PointObject.new(x-@x, y-@y, z-@z)
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

    def to_i
        return PointObject.new(@x.to_i, @y.to_i, @z.to_i)
    end
end
