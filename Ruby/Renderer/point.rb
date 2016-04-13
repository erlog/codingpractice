require_relative 'c_optimization'; include C_Optimization

class PointObject
    attr_reader :id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(x, y, z)
        @x = x; @y = y; @z = z
    end

    def self.from_array(xyz)
        @x, @y, @z = xyz.to_a
        return PointObject.new(@x, @y, @z)
    end

    def to_s
        return "PointObject.new(#{@x}, #{@y}, #{z})"
    end

    def to_i!
        @x = @x.to_i; @y = @y.to_i; @z = @z.to_i
        return self
    end

    def round!
        @x = @x.round; @y = @y.round
        return self
    end

    def xyz
        return [@x, @y, @z]
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

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
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

    def <=>(other)
        return 1 if @y < other.y
        return -1 if @y > other.y
        return -1 if @x < other.x
        return 1 if @x > other.x
        return 0
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

    def cross_product!(other)
        x = (@y*other.z) - (@z*other.y)
        y = (@z*other.x) - (@x*other.z)
        z = (@x*other.y) - (@y*other.x)
        @x = x; @y = y; @z = z
        return self
    end

    def cross_product(other)
        return self.dup.cross_product!(other)
    end

    def scale_by_factor!(factor)
        @x = @x * factor
        @y = @y * factor
        @z = @z * factor
        return self
    end

    def scale_by_factor(factor)
        return self.dup.scale_by_factor!(factor)
    end

    def scalar_product(other)
        return (@x*other.x) + (@y*other.y) + (@z*other.z)
    end

    def to_texture!(texture_size)
        @x = (@x * texture_size.x)
        @y = (@y * texture_size.y)
        return self
    end

    def to_screen!(center)
        #unrolled for performance
        @x = (center.x + (@x * center.x)).round
        @y = (center.y + (@y * center.y)).round
        @z = (center.z + (@z * center.z)).round
        return self
    end

    def to_screen(center)
        return self.dup.to_screen!(center)
    end

    def compute_reflection(light_direction)
        reflection = self.scale_by_factor(-2*self.scalar_product(light_direction))
        reflection += light_direction
        return normalize!(reflection)
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
end

def normalize(point)
    return normalize!(point.dup)
end

def normalize!(point)
    length = Math.sqrt( (point.x**2) + (point.y**2) + (point.z**2) )
    point.x /= length
    point.y /= length
    point.z /= length
    return point
end

def cartesian_to_barycentric(cart, verts)
    x,y,z = c_cartesian_to_barycentric(   cart.x, cart.y, cart.z,
                                          verts[0].x, verts[0].y, verts[0].z,
                                          verts[1].x, verts[1].y, verts[1].z,
                                          verts[2].x, verts[2].y, verts[2].z )
    return PointObject.new(x, y, z)
end

def barycentric_to_cartesian(bary, verts)
    x,y,z = c_barycentric_to_cartesian(   bary.x, bary.y, bary.z,
                                          verts[0].x, verts[0].y, verts[0].z,
                                          verts[1].x, verts[1].y, verts[1].z,
                                          verts[2].x, verts[2].y, verts[2].z )
    return PointObject.new(x, y, z)
end
