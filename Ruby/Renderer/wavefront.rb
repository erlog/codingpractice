class Wavefront
    attr_reader :faces

    def initialize(faces, vertices, uvs, normals)
        @vertices = vertices
        @uvs = uvs
        @normals = normals
        @tangents = Array.new(vertices.length){[]}
        @bitangents = Array.new(vertices.length){[]}

        #compute tangents/bitangents for tangent space normal mapping
        faces.each do |indexed_face|
            vertex_indices = indexed_face.map{ |vertex| vertex.v }
            face = self.build_face(indexed_face)
            tangent, bitangent = compute_face_tb(face)
            vertex_indices.each do |index|
                @tangents[index] << tangent
                @bitangents[index] << bitangent
            end
        end

        #average face tangent/bitangets to get t/b at individual vertices
        @tangents.map!{|group| group.inject(&:+).scale_by_factor(1.0/group.length) }
        @bitangents.map!{|group| group.inject(&:+).scale_by_factor(1.0/group.length) }

        #build our face objects
        face_objects = []
        faces.each do |indexed_face|
            face = self.build_face(indexed_face)
            verts = face.map(&:v)
            uvs = face.map(&:uv)
            normals = face.map(&:normal)
            tangents = face.map(&:tangent)
            bitangents = face.map(&:bitangent)
            face_objects << Face.new(verts, uvs, normals, tangents, bitangents)
        end
        @faces = face_objects
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

class Face
    attr_reader :verts
    attr_reader :uvs
    attr_reader :normal  #face normal for camera calculations
    attr_reader :normals #individual vertex normals for shading calculations
    attr_reader :tangents
    attr_reader :bitangents

    def initialize(verts, uvs, normals, tangents, bitangents)
        @verts = verts
        @uvs = uvs
        @normal = ((verts[1] - verts[0]).cross_product(verts[2] - verts[0])).normalize
        @normals = normals
        @tangents = tangents
        @bitangents = bitangents
    end

    def apply_matrix!(matrix)
        @vs.map!{ |vertex| vertex.apply_matrix(matrix) }
        return self
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


#There be dragons below, it was written to transform model scale to world scale
def find_normalizing_offset(numbers)
    return (numbers.max - (numbers.max - numbers.min)/2)*-1
end

#This "normalizes" as in rescales everything
def normalize_vectors(vectors)
        x_offset = find_normalizing_offset(vectors.map(&:x))
        y_offset = find_normalizing_offset(vectors.map(&:y))
        z_offset = find_normalizing_offset(vectors.map(&:z))
        offset = Point(x_offset, y_offset, z_offset)
        vectors.map!{ |vertex| vertex + offset }

        max = (vectors.map(&:x) + vectors.map(&:y) + vectors.map(&:z)).max
        return vectors.map!{ |vertex| vertex/Point(max, max, max)}
end

