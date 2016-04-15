require_relative 'c_optimization'; include C_Optimization

class Point
    attr_reader :id

    def to_s
        return "Point.new(#{self.x}, #{self.y}, #{self.z})"
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

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
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

    def cross_product(other)
        return self.dup.cross_product!(other)
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

    def to_screen(center)
        return self.dup.to_screen!(center)
    end

    def compute_reflection!(light_direction)
        reflection = self.scale_by_factor(-2*self.scalar_product(light_direction))
        reflection += light_direction
        return reflection.normalize!
    end

    def -(other)
        return self.dup.minus!(other)
    end

    def +(other)
        return self.dup.plus!(other)
    end

    def to_cartesian(verts)
        return self.dup.to_cartesian!(verts)
    end

    def normalize
        return self.dup.normalize!
    end
end

