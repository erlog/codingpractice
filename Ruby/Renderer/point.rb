require_relative 'c_optimization'; include C_Optimization

class Point
    attr_reader :id

    def to_s
        return "Point.new(#{self.x}, #{self.y}, #{self.z})"
    end

    def apply_matrix(matrix)
        return self.dup.apply_matrix!(matrix)
    end

    def hash
        return id.hash
    end

    def cross_product(other)
        return self.dup.cross_product!(other)
    end

    def scale_by_factor(factor)
        return self.dup.scale_by_factor!(factor)
    end

    def to_screen(center)
        return self.dup.to_screen!(center)
    end

    def to_cartesian(verts)
        return self.dup.to_cartesian!(verts)
    end

    def normalize
        return self.dup.normalize!
    end
end

