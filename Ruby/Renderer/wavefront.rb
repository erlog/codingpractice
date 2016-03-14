class Wavefront
    attr_reader :vertices
    attr_reader :triangles

	def initialize(file_path)
        @vertices = []
        @triangles = []
        lines = open(file_path).readlines.map!(&:strip)
        lines.each do |line|
            parts = line.split(" ")
            if parts[0] == "v"
                x, y, z = parts[1..-1].map(&:to_f)
                @vertices << Point(x, y, z)

            elsif parts[0] == "f"
                vertices = []
                parts[1..-1].each do |part|
                    vertices << part.split("/")[0].to_i - 1
                end
                @triangles << vertices
            end

        end

        #normalize vertices
        @vertices = normalize_vectors(@vertices)

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


