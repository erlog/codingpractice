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

        #vertices = normalize_vectors(vertices)
        return Wavefront.new(vertices, texture_vertices, normal_vertices, faces)
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
        return ((@v[1] - @v[0]).cross_product(@v[2] - @v[0])).normalize
    end

    def compute_tb #tangent/bitangent
        q1 = @v[1] - @v[0]; q2 = @v[2] - @v[0]
        s1t1 = @vt[1] - @vt[0]; s2t2 = @vt[2] - @vt[0]
        t,b = get_tb(q1, q2, s1t1, s2t2)
        return [t, b]
    end

    def apply_matrix(geom_matrix)
        v = @v.map{ |vertex| vertex.apply_matrix(geom_matrix) }
        return Face.new(v, @vt, vn)
    end

    def to_screen(center)
        return @v.map{ |vertex| vertex.to_screen(center) }
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

