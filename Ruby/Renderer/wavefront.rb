def find_normalizing_offset(numbers)
    min, max = numbers.min, numbers.max
    return (max - (max - min)/ 2)*-1
end

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

        x_offset = find_normalizing_offset(@vertices.map(&:x))
        y_offset = find_normalizing_offset(@vertices.map(&:y))
        z_offset = find_normalizing_offset(@vertices.map(&:z))
        offset = Point(x_offset, y_offset, z_offset)
        @vertices.map!{ |vertex| vertex + offset }

        max = (@vertices.map(&:x) + @vertices.map(&:y) + @vertices.map(&:z)).max
        @vertices.map!{ |vertex| vertex/Point(max, max, max)}

    end
end

