class Wavefront
    attr_reader :faces

    def initialize(faces, vertices, uvs, normals)
        @faces = faces #faces are just triplets of indexed vertices
        @vertices = vertices
        @uvs = uvs
        @normals = normals
        @tangents = Array.new(vertices.length){[]}
        @bitangents = Array.new(vertices.length){[]}

        #compute tangents/bitangents for tangent space normal mapping
        @faces.each do |indexed_face|
            vertex_indices = indexed_face.map{ |vertex| vertex.v }
            face = self.build_face(indexed_face)
            tangent, bitangent = compute_face_tb(face)
            vertex_indices.each do |index|
                @tangents[index] << tangent
                @bitangents[index] << bitangent
            end
        end
        #average face tangent to get tangents of individual vertices
        @tangents.map!{|group| group.inject(&:+) / Point(group.length, group.length, group.length) }
        @bitangents.map!{|group| group.inject(&:+) / Point(group.length, group.length, group.length) }
    end

    def each_face
        @faces.each do |indexed_face|
            yield build_face(indexed_face)
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
        lines.each do |line|
            parts = line.split(" ")
            if parts[0] == "v"
                x, y, z = parts[1..-1].map(&:to_f)
                vertices << Point(x, y, z)

            elsif parts[0] == "vt"
                x, y, z = parts[1..-1].map(&:to_f)
                uvs << Point(x, y, z)

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
    end
end

def compute_face_normal(face)
    a, b, c = face
    return ((b.v - a.v).cross_product(c.v - a.v)).normalize
end

def apply_matrix_to_face(face, matrix)
    a, b, c = face
    a.v = a.v.apply_matrix(matrix)
    b.v = b.v.apply_matrix(matrix)
    c.v = c.v.apply_matrix(matrix)
    return [a, b, c]
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

