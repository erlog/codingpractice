require 'matrix'

def compute_view_matrix(x, y, z, projection)
    cos, sin = cos_sin(degrees(x))
    x_matrix = get_x_matrix(cos, sin)
    cos, sin = cos_sin(degrees(y))
    y_matrix = get_y_matrix(cos, sin)
    cos, sin = cos_sin(degrees(z))
    z_matrix = get_z_matrix(cos, sin)
    projection_matrix = get_projection_matrix(projection)
    return z_matrix * y_matrix * x_matrix * projection_matrix
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

def get_tb(q1, q2, s1t1, s2t2)
    st_matrix = Matrix[ [s2t2.v, -1*s1t1.v],
                        [-1*s2t2.u, s1t1.u] ]
    q_matrix = Matrix[ [q1.x, q1.y, q1.z],
                       [q2.x, q2.y, q2.z] ]
    tb_matrix = (st_matrix * q_matrix)/(s1t1.u*s2t2.v - s2t2.u*s1t1.v)
    t = PointObject.from_array(tb_matrix.row(0)).normalize
    b = PointObject.from_array(tb_matrix.row(1)).normalize
    return [t, b]
end

def get_tbn_matrix(t, b, n)
    return Matrix.columns([t.xyz, b.xyz, n.xyz])
end

def cos_sin(radians)
    return [Math.cos(radians), Math.sin(radians)]
end

def degrees(radians)
    return radians * Math::PI / 180
end





