require_relative 'c_optimization'; include C_Optimization

class Point
    attr_reader :id
    attr_accessor :xyz

    def initialize(xyz)
        @xyz = xyz
    end

    def dup
        return Point.new([xyz[0], xyz[1], xyz[2]])
    end

    def to_s
        return "Point.new([#{@xyz[0]}, #{@xyz[1]}, #{@xyz[2]}])"
    end

    def to_i!
        @xyz.map!(&:to_i)
        return self
    end

    def round!
        @xyz.map!(&:round)
        return self
    end

    def apply_matrix!(matrix)
        #matrix math unrolled for performance gains
        x = (matrix[0][0] * @xyz[0]) + (matrix[0][1] * @xyz[1]) + (matrix[0][2] * @xyz[2]) + matrix[0][3]
        y = (matrix[1][0] * @xyz[0]) + (matrix[1][1] * @xyz[1]) + (matrix[1][2] * @xyz[2]) + matrix[1][3]
        z = (matrix[2][0] * @xyz[0]) + (matrix[2][1] * @xyz[1]) + (matrix[2][2] * @xyz[2]) + matrix[2][3]
        d = (matrix[3][0] * @xyz[0]) + (matrix[3][1] * @xyz[1]) + (matrix[3][2] * @xyz[2]) + matrix[3][3]
        @xyz = [x/d, y/d, z/d]
        return self
    end

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
    end

    def apply_tangent_matrix!(tbn)
        #matrix math unrolled for performance gains
        tangent, bitangent, normal = tbn
        @xyz = [
            (tangent.xyz[0] * @xyz[0]) + (bitangent.xyz[0] * @xyz[1]) + (normal.xyz[0] * @xyz[2]),
            (tangent.xyz[1] * @xyz[0]) + (bitangent.xyz[1] * @xyz[1]) + (normal.xyz[1] * @xyz[2]),
            (tangent.xyz[2] * @xyz[0]) + (bitangent.xyz[2] * @xyz[1]) + (normal.xyz[2] * @xyz[2])]
        return self
    end

    def <=>(other)
        return 1 if @xyz[1] < other.xyz[1]
        return -1 if @xyz[1] > other.xyz[1]
        return -1 if @xyz[0] < other.xyz[0]
        return 1 if @xyz[0] > other.xyz[0]
        return 0
    end

    def hash
        id.hash
    end

    def eql?(other)
        return self == other
    end

    def ==(other)
        return false if @xyz[0] != other.xyz[0]
        return false if @xyz[1] != other.xyz[1]
        return false if @xyz[2] != other.xyz[2]
        return true
    end

    def cross_product!(other)
        @xyz = [ (@xyz[1]*other.xyz[2]) - (@xyz[2]*other.xyz[1]),
                 (@xyz[2]*other.xyz[0]) - (@xyz[0]*other.xyz[2]),
                 (@xyz[0]*other.xyz[1]) - (@xyz[1]*other.xyz[0]) ]
        return self
    end

    def cross_product(other)
        return self.dup.cross_product!(other)
    end

    def scale_by_factor!(factor)
        @xyz = [ @xyz[0] * factor,
                 @xyz[1] * factor,
                 @xyz[2] * factor ]
        return self
    end

    def scale_by_factor(factor)
        return self.dup.scale_by_factor!(factor)
    end

    def scalar_product(other)
        return (@xyz[0]*other.xyz[0]) + (@xyz[1]*other.xyz[1]) + (@xyz[2]*other.xyz[2])
    end

    def to_texture!(texture_size)
        @xyz = [ (@xyz[0] * texture_size.xyz[0]),
                 (@xyz[1] * texture_size.xyz[1]),
                  @xyz[2] ]
        return self
    end

    def to_screen!(center)
        #unrolled for performance
        @xyz = [ (center.xyz[0] + (@xyz[0] * center.xyz[0])).round,
                 (center.xyz[1] + (@xyz[1] * center.xyz[1])).round,
                 (center.xyz[2] + (@xyz[2] * center.xyz[2])).round ]
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
        return Point.new([@xyz[0]+other.xyz[0], @xyz[1]+other.xyz[1], @xyz[2]+other.xyz[2]])
    end

    def -(other)
        return Point.new([@xyz[0]-other.xyz[0], @xyz[1]-other.xyz[1], @xyz[2]-other.xyz[2]])
    end

    def /(other)
        return Point.new([@xyz[0]/other.xyz[0], @xyz[1]/other.xyz[1], @xyz[2]/other.xyz[2]])
    end
end

def normalize(point)
    return normalize!(point.dup)
end

def normalize!(point)
    point.xyz = c_normalize(point.xyz)
    return point
end

def cartesian_to_barycentric!(cart, verts)
    cart.xyz = c_cartesian_to_barycentric(cart.xyz, verts[0].xyz, verts[1].xyz, verts[2].xyz)
    return cart
end

def barycentric_to_cartesian(bary, verts)
    xyz = c_barycentric_to_cartesian(bary.xyz, verts[0].xyz, verts[1].xyz, verts[2].xyz)
    return Point.new(xyz)
end
