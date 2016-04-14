require_relative 'c_optimization'; include C_Optimization

class Point
    attr_reader :id

    def dup
        return Point.new([self.x, self.y, self.z])
    end

    def to_i!
        self.x = self.x.to_i
        self.y = self.y.to_i
        return self
    end

    def round!
        self.x = self.x.round
        self.y = self.y.round
        return self
    end

    def apply_matrix!(matrix)
        #matrix math unrolled for performance gains
        x = (matrix[0][0] * self.x) + (matrix[0][1] * self.y) + (matrix[0][2] * self.z) + matrix[0][3]
        y = (matrix[1][0] * self.x) + (matrix[1][1] * self.y) + (matrix[1][2] * self.z) + matrix[1][3]
        z = (matrix[2][0] * self.x) + (matrix[2][1] * self.y) + (matrix[2][2] * self.z) + matrix[2][3]
        d = (matrix[3][0] * self.x) + (matrix[3][1] * self.y) + (matrix[3][2] * self.z) + matrix[3][3]
        self.x = x/d
        self.y = y/d
        self.z = z/d
        return self
    end

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
    end

    def apply_tangent_matrix!(tbn)
        #matrix math unrolled for performance gains
        tangent, bitangent, normal = tbn
        x = (tangent.x * self.x) + (bitangent.x * self.y) + (normal.x * self.z)
        y = (tangent.y * self.x) + (bitangent.y * self.y) + (normal.y * self.z)
        z = (tangent.z * self.x) + (bitangent.z * self.y) + (normal.z * self.z)
        self.x = x
        self.y = y
        self.z = z
        return self
    end

    def <=>(other)
        return 1 if self.y < other.y
        return -1 if self.y > other.y
        return -1 if self.x < other.x
        return 1 if self.x > other.x
        return 0
    end

    def hash
        id.hash
    end

    def eql?(other)
        return self == other
    end

    def ==(other)
        return false if self.x != other.x
        return false if self.y != other.y
        return false if self.z != other.z
        return true
    end

    def cross_product!(other)
        self.x = (self.y*other.z) - (self.z*other.y)
        self.y = (self.z*other.x) - (self.x*other.z)
        self.z = (self.x*other.y) - (self.y*other.x)
        return self
    end

    def cross_product(other)
        return self.dup.cross_product!(other)
    end

    def scale_by_factor!(factor)
        self.x *= factor
        self.y *= factor
        self.z *= factor
        return self
    end

    def scale_by_factor(factor)
        return self.dup.scale_by_factor!(factor)
    end

    def scalar_product(other)
        return (self.x*other.x) + (self.y*other.y) + (self.z*other.z)
    end

    def to_texture!(texture_size)
        self.x = (self.x * texture_size.x)
        self.y = (self.y * texture_size.y)
        return self
    end

    def to_screen!(center)
        #unrolled for performance
        self.x = (center.x + (self.x * center.x)).round
        self.y = (center.y + (self.y * center.y)).round
        self.z = (center.z + (self.z * center.z))
        return self
    end

    def to_screen(center)
        return self.dup.to_screen!(center)
    end

    def compute_reflection!(light_direction)
        reflection = self.scale_by_factor(-2*self.scalar_product(light_direction))
        reflection += light_direction
        return reflection.normalize!
    end

    def +(other)
        return Point.new([self.x+other.x, self.y+other.y, self.z+other.z])
    end

    def -(other)
        return Point.new([self.x-other.x, self.y-other.y, self.z-other.z])
    end

    def /(other)
        return Point.new([self.x/other.x, self.y/other.y, self.z/other.z])
    end

    def to_cartesian(verts)
        return self.dup.to_cartesian!(verts)
    end
end

