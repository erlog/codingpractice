class Wavefront
    attr_reader :faces

    def initialize(faces, vertices, uvs, normals)
        @vertices = vertices
        @uvs = uvs
        @normals = normals
        @tangents = Array.new(vertices.length){[]}
        @bitangents = Array.new(vertices.length){[]}

        #compute tangents/bitangents for tangent space normal mapping
        for indexed_face in faces
            vertex_indices = indexed_face.map{ |vertex| vertex.v }
            face = self.build_face(indexed_face)
            tangent, bitangent = compute_face_tb(face)
            for index in vertex_indices
                @tangents[index] << tangent
                @bitangents[index] << bitangent
            end
        end
        @faces = faces

        #average face tangent/bitangets to get t/b at individual vertices
        @tangents.map!{|group| group.inject(&:+).scale_by_factor(1.0/group.length) }
        @bitangents.map!{|group| group.inject(&:+).scale_by_factor(1.0/group.length) }
    end

    def each_face
        for indexed_face in @faces
            yield self.build_face(indexed_face)
        end
    end

    def build_face(indexed_face)
        return indexed_face.map{ |vertex| self.build_vertex(vertex) }
    end

    def build_vertex(vertex)
        v = @vertices[vertex.v]
        uv = @uvs[vertex.uv]
        normal = @normals[vertex.normal]
        tangent = @tangents[vertex.v]
        bitangent = @bitangents[vertex.v]

        return Vertex.new(v, uv, normal, tangent, bitangent)
    end

	def self.from_file(file_path)
        log("Loading model: #{file_path}")
        faces, vertices, uvs, normals  = [], [], [], []

        lines = open(file_path).readlines.map!(&:strip)
        for line in lines
            parts = line.split(" ")
            if parts[0] == "v"
                x, y, z = parts[1..-1].map(&:to_f)
                vertices << Point.new([x, y, z])

            elsif parts[0] == "vt"
                x, y, z = parts[1..-1].map(&:to_f)
                uvs << Point.new([x, y, z])

            elsif parts[0] == "vn"
                x, y, z = parts[1..-1].map(&:to_f)
                normals << Point.new([x, y, z])

            elsif parts[0] == "f"
                v, vt, vn = parts[1].split("/").map{ |index| index.to_i - 1}
                a = Vertex.new(v, vt, vn)
                v, vt, vn = parts[2].split("/").map{ |index| index.to_i - 1}
                b = Vertex.new(v, vt, vn)
                v, vt, vn = parts[3].split("/").map{ |index| index.to_i - 1}
                c = Vertex.new(v, vt, vn)
                faces << [a, b, c]
            end
        end

        return Wavefront.new(faces, vertices, uvs, normals)
    end
end

class Vertex
    attr_accessor :v
    attr_reader :uv
    attr_reader :normal
    attr_reader :tangent
    attr_reader :bitangent

    def initialize(geometric_vertex, texture_coordinate, normal, bitangent = nil, tangent = nil)
        @v = geometric_vertex
        @uv = texture_coordinate
        @normal = normal
        @tangent = tangent
        @bitangent = bitangent
        @screen_v = nil
    end
end

def compute_face_normal(face)
    a, b, c = face
    return (b.v - a.v).cross_product(c.v - a.v).normalize!
end

def face_to_screen(face, view_matrix, screen_center)
    face = face.dup
    face[0].v = face[0].v.dup.apply_matrix(view_matrix).to_screen!(screen_center)
    face[1].v = face[1].v.dup.apply_matrix(view_matrix).to_screen!(screen_center)
    face[2].v = face[2].v.dup.apply_matrix(view_matrix).to_screen!(screen_center)
    face = face.sort_by(&:v)
    return face
end

#There be dragons below, it was written to transform model scale to world scale
def find_normalizing_offset(numbers)
    return (numbers.max - (numbers.max - numbers.min)/2)*-1
end

#This "normalizes" as in rescales everything
def normalize_vectors(vectors)
        x_offset = find_normalizing_offset(vectors.map(&:x))
        y_offset = find_normalizing_offset(vectors.map(&:y))
        z_offset = find_normalizing_offset(vectors.map(&:z))
        offset = Point.new([x_offset, y_offset, z_offset])
        vectors.map!{ |vertex| vertex + offset }

        max = (vectors.map(&:x) + vectors.map(&:y) + vectors.map(&:z)).max
        return vectors.map!{ |vertex| vertex/Point.new([max, max, max])}
end

