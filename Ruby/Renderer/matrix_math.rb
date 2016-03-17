require 'matrix'

def compute_view_matrix(x, y, z, projection)
    cos, sin = cos_sin(degrees(x))
    x_matrix = get_x_matrix(cos, sin)
    cos, sin = cos_sin(degrees(y))
    y_matrix = get_y_matrix(cos, sin)
    cos, sin = cos_sin(degrees(z))
    z_matrix = get_z_matrix(cos, sin)
    projection_matrix = get_projection_matrix(projection)
    return projection_matrix * z_matrix * y_matrix * x_matrix
end

def get_x_matrix(cos, sin)
    return Matrix[  [1, 0, 0, 0],
                    [0, cos, sin*-1, 0],
                    [0, sin, cos, 0],
                    [0, 0, 0, 1] ]
end

def get_y_matrix(cos, sin)
    return Matrix[  [cos, 0, sin, 0],
                    [0, 1, 0, 0],
                    [sin*-1, 0, cos, 0],
                    [0, 0, 0, 1] ]
end

def get_z_matrix(cos, sin)
    return Matrix[  [cos, sin*-1, 0, 0],
                    [sin, cos, 0, 0],
                    [0, 0, 1, 0],
                    [0, 0, 0, 1] ]
end

def get_projection_matrix(c)
    return Matrix[  [1, 0, 0, 0],
                    [0, 1, 0, 0],
                    [0, 0, 1, 0],
                    [0, 0, -1.0/c, 1] ]
end

def cos_sin(radians)
    return [Math.cos(radians), Math.sin(radians)]
end

def degrees(radians)
    return radians * Math::PI / 180
end




