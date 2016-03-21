class Wavefront
    attr_reader :faces

    def initialize(faces, vertices)
        @faces = faces
        @vertices = vertices

        @faces.each do |indexed_face|
            face = build_face(indexed_face)
            tangent, bitangent = face.compute_tb

    end

    def build_face(face)
        a, b, c = face.abc.map{ |vertex| self.build_vertex(vertex) }
        return Face.new(a, b, c)
    end

    def build_vertex(vertex)
        vertex = vertex.dup
        vertex.v = @vertices[vertex.v]
        vertex.vt = @texture_vertices[vertex.vt]
        vertex.n = @normals[vertex.n]
        return vertex
    end

	def self.from_file(file_path)
        faces = []
        vertices = []
        texture_vertices = []
        normals = []
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
                normals << Point(x, y, z)

            elsif parts[0] == "f"
                v, vt, vn = parts[1].split("/").map{ |index| index.to_i - 1}
                a = Vertex.new(v, vt, vn)
                v, vt, vn = parts[2].split("/").map{ |index| index.to_i - 1}
                b = Vertex.new(v, vt, vn)
                v, vt, vn = parts[3].split("/").map{ |index| index.to_i - 1}
                c = Vertex.new(v, vt, vn)
                faces << Face.new(a, b, c)
            end
        end

        (0..vertices.length - 1).each do |index|
            v, vt, n = vertices[i], texture_vertices[i], normals[i]
            vertices[i] = Vertex(u, vt, n)
        end

        return Wavefront.new(faces, vertices)
    end
end

class Vertex
    attr_accessor :v
    attr_accessor :uv
    attr_accessor :normal
    attr_accessor :tangents
    attr_accessor :bitangents

    def initialize(geometric_vertex, texture_coordinate, normal)
        @v = geometric_vertex
        @uv = texture_coordinate
        @normal = normal
        @tangent = nil
        @tangents = []
        @bitangent = nil
        @bitangents = []
    end
end

class Face
    attr_reader :a
    attr_reader :b
    attr_reader :c

    def initialize(a, b, c)
        a, b, c = [a, b, c].sort_by{ |vertex| vertex.v.x }
        @a = a; @b = b; @c = c
    end

    def compute_normal
        return ((@b.v - @a.v).cross_product(@c.v - @a.v)).normalize
    end

    def abc
        return [@a, @b, @c]
    end

    def v
        return [@a, @b, @c].map(&:v)
    end

    def vt
        return [@a, @b, @c].map(&:uv)
    end

    def uv
        return self.vt
    end

    def vn
        return [@a, @b, @c].map(&:normal)
    end

    def to_s
        return [self.v.to_s].join("\n") + "-------\n"
    end

    def to_screen(screen_center)
        return self.v.map{ |vertex| vertex.to_screen(screen_center) }
    end

    def compute_tb #tangent/bitangent
        q1 = @b.v - @a.v; q2 = @c.v - @a.v
        s1t1 = @b.uv - @a.uv; s2t2 = @c.uv - @a.uv
        t,b = get_tb(q1, q2, s1t1, s2t2)
        return [t, b]
    end
end


#There be dragons below, it was written to transform model scale to world scale
def find_normalizing_offset(numbers)
    return (numbers.max - (numbers.max - numbers.min)/2)*-1
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

