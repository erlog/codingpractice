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

        #normalize vertices above zero
        x = @vertices.map(&:x).max
        y = @vertices.map(&:y).max
        z = @vertices.map(&:z).max
        @vertices.map!{ |vertex| vertex.normalize(x, y, z) }

    end
end

