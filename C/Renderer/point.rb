require_relative 'c_optimization'; include C_Optimization

class Point
#these are debug and convenience methods for the point class that exists in
#   c_point.c
#
    attr_reader :id

    def rgb
        point = self.normalize
        r = (point.x*127) + 128
        g = (point.y*127) + 128
        b = (point.z*127) + 128
        return [r, g, b]
    end

    def self.from_array(xyz)
        return Point.new(xyz[0], xyz[1], xyz[2])
    end

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

