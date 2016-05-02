class Indexed_Vertex
    #Shim class to load indexed vertex information in before processing and
    #sending to C_Vertex which requires proper Point* objects instead of ints
    attr_accessor :v; attr_accessor :uv; attr_accessor :normal;
    def initialize(geometric_vertex, texture_coordinate, normal)
        @v = geometric_vertex; @uv = texture_coordinate; @normal = normal;
    end
end

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
            face = indexed_face.map{ |vertex|
                    vertex = vertex.dup
                    vertex.v = @vertices[vertex.v]
                    vertex.uv = @uvs[vertex.uv]
                    vertex.normal = @normals[vertex.normal]
                    vertex
                    }
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

        #Send everything over to C
        @faces.map!{ |indexed_face| self.build_face(indexed_face) }
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
        return C_Vertex.new(v, uv, normal, tangent, bitangent)
    end

	def self.from_file(file_path)
        log("Loading model: #{file_path}")
        faces, vertices, uvs, normals  = [], [], [], []

        lines = open(file_path).readlines.map!(&:strip)
        for line in lines
            parts = line.split(" ")
            if parts[0] == "v"
                x, y, z = parts[1..-1].map(&:to_f)
                vertices << Point.new(x, y, z)

            elsif parts[0] == "vt"
                x, y, z = parts[1..-1].map(&:to_f)
                uvs << Point.new(x, y, z)

            elsif parts[0] == "vn"
                x, y, z = parts[1..-1].map(&:to_f)
                normals << Point.new(x, y, z)

            elsif parts[0] == "f"
                v, vt, vn = parts[1].split("/").map{ |index| index.to_i - 1}
                a = Indexed_Vertex.new(v, vt, vn)
                v, vt, vn = parts[2].split("/").map{ |index| index.to_i - 1}
                b = Indexed_Vertex.new(v, vt, vn)
                v, vt, vn = parts[3].split("/").map{ |index| index.to_i - 1}
                c = Indexed_Vertex.new(v, vt, vn)
                faces << [a, b, c]
            end
        end

        return Wavefront.new(faces, vertices, uvs, normals)
    end
end

def face_to_screen(face, view_matrix, screen_center)
    face = face.dup
    face[0].v = face[0].v.dup.apply_matrix!(view_matrix).to_screen!(screen_center)
    face[1].v = face[1].v.dup.apply_matrix!(view_matrix).to_screen!(screen_center)
    face[2].v = face[2].v.dup.apply_matrix!(view_matrix).to_screen!(screen_center)
    face = face.sort_by(&:v)
    return face
end

def compute_face_normal(face)
    a, b, c = face
    return ((b.v - a.v).cross_product(c.v - a.v)).normalize!
end

