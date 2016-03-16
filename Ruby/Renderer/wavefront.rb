
class Wavefront
    attr_accessor :vertices
    attr_reader :faces

    def initialize(vertices, texture_vertices, normal_vertices, faces)
        @vertices = vertices
        @texture_vertices = texture_vertices
        @normal_vertices = normal_vertices
        @faces = faces
    end

	def self.from_file(file_path)
        vertices = []
        texture_vertices = []
        normal_vertices = []
        faces = []
        lines = open(file_path).readlines.map!(&:strip)
        lines.each do |line|
            parts = line.split(" ")
            if parts[0] == "v"
                x, y, z = parts[1..-1].map(&:to_f)
                vertices << Point(x, y, z)

            elsif parts[0] == "vt"
                x, y, z = parts[1..-1].map(&:to_f)
                texture_vertices << Point(x, y, z)

            elsif parts[0] == "vn"
                x, y, z = parts[1..-1].map(&:to_f)
                normal_vertices << Point(x, y, z)

            elsif parts[0] == "f"
                x, y, z = parts[1..-1].map{ |x| x.split("/")[0].to_i - 1 }
                triangle = [x, y, z]
                x, y, z = parts[1..-1].map{ |x| x.split("/")[1].to_i - 1 }
                texture_triangle = [x, y, z]
                x, y, z = parts[1..-1].map{ |x| x.split("/")[2].to_i - 1 }
                normal_triangle = [x, y, z]

                faces << Face.new(triangle, texture_triangle, normal_triangle)
            end
        end

        vertices = normalize_vectors(vertices)
        return Wavefront.new(vertices, texture_vertices, normal_vertices, faces)
    end

    def rotate(x = nil, y = nil, z = nil)
        model = self.dup
        if x
            cos, sin = cos_sin(degrees(x))
            model.vertices.map!{ |vertex| vertex.rotate_x(cos, sin) }
        end
        if y
            cos, sin = cos_sin(degrees(y))
            model.vertices.map!{ |vertex| vertex.rotate_y(cos, sin) }
        end
        if z
            cos, sin = cos_sin(degrees(z))
            model.vertices.map!{ |vertex| vertex.rotate_z(cos, sin) }
        end
        return model
    end

    def each_face
        @faces.each do |face|
            face.v = face.v.map{ |index| @vertices[index] }
            face.vt = face.vt.map{ |index| @texture_vertices[index] }
            face.vn = face.vn.map{ |index| @normal_vertices[index] }
            yield face
        end
    end
end

class Face
    attr_accessor :v
    attr_accessor :vt
    attr_accessor :vn
    def initialize(v, vt, vn)
        @v = v; @vt = vt; @vn = vn
    end

    def compute_normal
        a, b, c = @v
        return (c - a).cross_product(b - a).normalize
    end

    def to_screen(center)
        return @v.map{ |vertex| vertex.to_screen(center) }
    end

    def project(distance)
        v = @v.map{ |vertex| vertex.project(distance) }
        vt = @vt.map{ |vertex| vertex.project(distance) }
        vn = @vn.map{ |vertex| vertex.project(distance) }
        return Face.new(v, vt, vn)
    end
end

def find_normalizing_offset(numbers)
    return (numbers.max - (numbers.max - numbers.min)/ 2)*-1
end

def normalize_vectors(vectors)
        x_offset = find_normalizing_offset(vectors.map(&:x))
        y_offset = find_normalizing_offset(vectors.map(&:y))
        z_offset = find_normalizing_offset(vectors.map(&:z))
        offset = Point(x_offset, y_offset, z_offset)
        vectors.map!{ |vertex| vertex + offset }

        max = (vectors.map(&:x) + vectors.map(&:y) + vectors.map(&:z)).max
        return vectors.map!{ |vertex| vertex/Point(max, max, max)}
end

def cos_sin(radians)
    return [Math.cos(radians), Math.sin(radians)]
end

def degrees(radians)
    return radians * Math::PI / 180
end
