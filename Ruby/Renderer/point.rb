require_relative 'c_optimization'; include C_Optimization

class Point
    attr_reader :id
    attr_accessor :xyz

    def initialize(xyz)
        @xyz = xyz
    end

    def to_s
        return "Point.new([#{@xyz[0]}, #{@xyz[1]}, #{@xyz[2]}])"
    end

    def to_i!
        @xyz[0] = @xyz[0].to_i; @xyz[1] = @xyz[1].to_i; @xyz[2] = @xyz[2].to_i
        return self
    end

    def round!
        @xyz[0] = @xyz[0].round; @xyz[1] = @xyz[1].round
        return self
    end

    def x; return @xyz[0]; end;
    def y; return @xyz[1]; end;
    def z; return @xyz[2]; end;
    def x=(value); @xyz[0] = value; end;
    def y=(value); @xyz[1] = value; end;
    def z=(value); @xyz[2] = value; end;

    def apply_matrix!(matrix)
        #matrix math unrolled for performance gains
        x = (matrix[0][0] * @xyz[0]) + (matrix[0][1] * @xyz[1]) + (matrix[0][2] * @xyz[2]) + matrix[0][3]
        y = (matrix[1][0] * @xyz[0]) + (matrix[1][1] * @xyz[1]) + (matrix[1][2] * @xyz[2]) + matrix[1][3]
        z = (matrix[2][0] * @xyz[0]) + (matrix[2][1] * @xyz[1]) + (matrix[2][2] * @xyz[2]) + matrix[2][3]
        d = (matrix[3][0] * @xyz[0]) + (matrix[3][1] * @xyz[1]) + (matrix[3][2] * @xyz[2]) + matrix[3][3]
        @xyz[0] = x/d; @xyz[1] = y/d; @xyz[2] = z/d    #parallel assignments are slower
        return self
    end

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
    end

    def apply_tangent_matrix!(tbn)
        #matrix math unrolled for performance gains
        tangent, bitangent, normal = tbn
        x = (tangent.x * @xyz[0]) + (bitangent.x * @xyz[1]) + (normal.x * @xyz[2])
        y = (tangent.y * @xyz[0]) + (bitangent.y * @xyz[1]) + (normal.y * @xyz[2])
        z = (tangent.z * @xyz[0]) + (bitangent.z * @xyz[1]) + (normal.z * @xyz[2])
        @xyz[0] = x; @xyz[1] = y; @xyz[2] = z    #parallel assignments are slower
        return self
    end

    def <=>(other)
        return 1 if @xyz[1] < other.y
        return -1 if @xyz[1] > other.y
        return -1 if @xyz[0] < other.x
        return 1 if @xyz[0] > other.x
        return 0
    end

    def hash
        id.hash
    end

    def eql?(other)
        return self == other
    end

    def ==(other)
        return false if @xyz[0] != other.x
        return false if @xyz[1] != other.y
        return false if @xyz[2] != other.z
        return true
    end

    def cross_product!(other)
        x = (@xyz[1]*other.z) - (@xyz[2]*other.y)
        y = (@xyz[2]*other.x) - (@xyz[0]*other.z)
        z = (@xyz[0]*other.y) - (@xyz[1]*other.x)
        @xyz[0] = x; @xyz[1] = y; @xyz[2] = z
        return self
    end

    def cross_product(other)
        return self.dup.cross_product!(other)
    end

    def scale_by_factor!(factor)
        @xyz[0] = @xyz[0] * factor
        @xyz[1] = @xyz[1] * factor
        @xyz[2] = @xyz[2] * factor
        return self
    end

    def scale_by_factor(factor)
        return self.dup.scale_by_factor!(factor)
    end

    def scalar_product(other)
        return (@xyz[0]*other.x) + (@xyz[1]*other.y) + (@xyz[2]*other.z)
    end

    def to_texture!(texture_size)
        @xyz[0] = (@xyz[0] * texture_size.x)
        @xyz[1] = (@xyz[1] * texture_size.y)
        return self
    end

    def to_screen!(center)
        #unrolled for performance
        @xyz[0] = (center.x + (@xyz[0] * center.x)).round
        @xyz[1] = (center.y + (@xyz[1] * center.y)).round
        @xyz[2] = (center.z + (@xyz[2] * center.z)).round
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
        return Point.new([@xyz[0]+other.x, @xyz[1]+other.y, @xyz[2]+other.z])
    end

    def -(other)
        return Point.new([@xyz[0]-other.x, @xyz[1]-other.y, @xyz[2]-other.z])
    end

    def /(other)
        return Point.new([@xyz[0]/other.x, @xyz[1]/other.y, @xyz[2]/other.z])
    end
end

def normalize(point)
    return normalize!(point.dup)
end

def normalize!(point)
    length = Math.sqrt( (point.x**2) + (point.y**2) + (point.z**2) )
    point.x = point.x/length
    point.y = point.y/length
    point.z = point.z/length
    return point
end

def cartesian_to_barycentric(cart, verts)
    x,y,z = c_cartesian_to_barycentric(cart.xyz, verts[0].xyz, verts[1].xyz, verts[2].xyz)
    return Point.new([x, y, z])
end

def barycentric_to_cartesian(bary, verts)
    x,y,z = c_barycentric_to_cartesian(bary.xyz, verts[0].xyz, verts[1].xyz, verts[2].xyz)
    return Point.new([x, y, z])
end
