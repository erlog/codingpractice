require 'matrix'

def compute_matrices(x, y, z, projection)
    cos, sin = cos_sin(degrees(x))
    x_matrix = get_x_matrix(cos, sin)
    cos, sin = cos_sin(degrees(y))
    y_matrix = get_y_matrix(cos, sin)
    cos, sin = cos_sin(degrees(z))
    z_matrix = get_z_matrix(cos, sin)
    projection_matrix = get_projection_matrix(projection)

    view_matrix = z_matrix * y_matrix * x_matrix * projection_matrix
    c_view_matrix = C_Matrix.new(view_matrix.to_a.flatten)
    c_normal_matrix = C_Matrix.new(view_matrix.inverse.transpose.to_a.flatten)
    return [c_view_matrix, c_normal_matrix]
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

def compute_face_tb(face) #tangent/bitangent
    a, b, c = face
    q1 = b.v - a.v; q2 = c.v - a.v
    s1t1 = b.uv - a.uv; s2t2 = c.uv - a.uv
    if s1t1 == s2t2 #otherwise we get NaN trying to divide infinity
        s1t1 = Point.new(1.0, 0.0, 0.0)
        s2t2 = Point.new(0.0, 1.0, 0.0)
    end
    st_matrix = Matrix[ [s2t2.v, -1*s1t1.v],
                        [-1*s2t2.u, s1t1.u] ]
    q_matrix = Matrix[ [q1.x, q1.y, q1.z],
                       [q2.x, q2.y, q2.z] ]
    tb_matrix = (st_matrix * q_matrix)/(s1t1.u*s2t2.v - s1t1.v*s2t2.u)
    t = Point.from_array(tb_matrix.row(0)).normalize
    b = Point.from_array(tb_matrix.row(1)).normalize
    return [t,b]
end

def cos_sin(radians)
    return [Math.cos(radians), Math.sin(radians)]
end

def degrees(radians)
    return radians * Math::PI / 180
end





