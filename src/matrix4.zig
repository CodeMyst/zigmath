const testing = @import("std").testing;
const math = @import("std").math;
const v4 = @import("vector4.zig").v4;
const v3 = @import("vector3.zig").v3;
const warn = @import("std").debug.warn;

pub const m4 = struct {
    v: [4][4]f32,

    /// returns a new identity matrix
    pub fn init() m4 {
        const ident = [4][4]f32 {
            [_]f32{1, 0, 0, 0},
            [_]f32{0, 1, 0, 0},
            [_]f32{0, 0, 1, 0},
            [_]f32{0, 0, 0, 1},
        };

        return m4 {
            .v = ident,
        };
    }

    /// creates a scaling matrix from the passed v4
    pub fn scaling(vec: v4) m4 {
        const res = [4][4]f32 {
            [_]f32{vec.x, 0, 0, 0},
            [_]f32{0, vec.y, 0, 0},
            [_]f32{0, 0, vec.z, 0},
            [_]f32{0, 0, 0, vec.w},
        };

        return m4 {
            .v = res,
        };
    }

    /// creates a rotation matrix. angle must be in radians
    pub fn rotation(angle: f32, axis: v3) m4 {
        var res = m4.init();

        const c = math.cos(angle);
        const c1 = 1 - c;
        const s = math.sin(angle);

        const a = axis.normalized();

        res.set(0, 0, a.x * a.x * c1 + c);
        res.set(0, 1, a.x * a.y * c1 - a.z * s);
        res.set(0, 2, a.x * a.z * c1 + a.y * s);
        res.set(1, 0, a.y * a.x * c1 + a.z * s);
        res.set(1, 1, a.y * a.y * c1 + c);
        res.set(1, 2, a.y * a.z * c1 - a.x * s);
        res.set(2, 0, a.z * a.x * c1 - a.y * s);
        res.set(2, 1, a.z * a.y * c1 + a.x * s);
        res.set(2, 2, a.z * a.z * c1 + c);

        return res;
    }

    /// creates a translation matrix
    pub fn translation(v: v3) m4 {
        var res = m4.init();

        var i: u16 = 0;

        while (i < 3) : (i += 1) {
            res.set(i, 3, res.at(i, 3) + v.at(i));
        }

        return res;
    }

    /// creates a look at matrix
    pub fn lookAt(eye: v3, target: v3, up: v3) m4 {
        const z = eye.subv(target).normalized();
        const x = up.neg().cross(z).normalized();
        const y = z.cross(x.neg());

        const l = [4][4]f32 {
            [_]f32{-x.x, -x.y, -x.z,  x.dot(eye)},
            [_]f32{ y.x,  y.y,  y.z, -y.dot(eye)},
            [_]f32{ z.x,  z.y,  z.z, -z.dot(eye)},
            [_]f32{ 0,    0,    0,    1 },
        };

        return m4 {
            .v = l,
        };
    }

    /// creates an orthographic projection matrix
    pub fn orthographic(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) m4 {
        const dx = right - left;
        const dy = top - bottom;
        const dz = far - near;
        
        const tx = -(right + left) / dx;
        const ty = -(top + bottom) / dy;
        const tz = -(far + near) / dz;

        const l = [4][4]f32 {
            [_]f32{2/dx, 0,    0,     tx},
            [_]f32{0,    2/dy, 0,     ty},
            [_]f32{0,    0,   -2/dz,  tz},
            [_]f32{0,    0,    0,     1},
        };

        return m4 {
            .v = l,
        };
    }

    /// creates a perspective projection matrix. fov is in radians
    pub fn perspective(fov: f32, aspect: f32, near: f32, far: f32) m4 {
        const f = 1 / (math.tan(fov/2));
        const d = 1 / (near - far);

        const l = [4][4]f32 {
            [_]f32{f/aspect, 0, 0, 0},
            [_]f32{0, f, 0, 0},
            [_]f32{0, 0, (far + near) * d, 2 * d * far * near},
            [_]f32{0, 0, -1, 0},
        };

        return m4 {
            .v = l,
        };
    }

    /// returns the value at [i, j]
    pub fn at(m: m4, i: u16, j: u16) f32 {
        return m.v[i][j];
    }

    /// sets the value at [i, j]
    pub fn set(m: *m4, i: u16, j: u16, val: f32) void {
        m.v[i][j] = val;
    }

    /// returns the mul of an m4 with a scalar
    pub fn muls(m: m4, s: f32) m4 {
        var res = m4.init();

        var i: u16 = 0;
        var j: u16 = 0;

        while (i < 4) : (i += 1) {
            j = 0;

            while (j < 4) : (j += 1) {
                res.set(i, j, m.at(i, j) * s);
            }
        }

        return res;
    }

    /// returns the mul of an m4 with a v4
    pub fn mulv(m: m4, v: v4) v4 {
        var res = v4.init(0, 0, 0, 0);

        var i: u16 = 0;
        var j: u16 = 0;

        while (i < 4) : (i += 1) {
            j = 0;

            var sum: f32 = 0;

            while (j < 4) : (j += 1) {
                sum += m.at(i, j) * v.at(j);
            }

            res.set(i, sum);
        }

        return res;
    }

    /// returns the mul of an m4 with another m4
    pub fn mulm(a: m4, b: m4) m4 {
        var res = m4.init();

        var i: u16 = 0;
        var j: u16 = 0;
        var k: u16 = 0;

        while (i < 4) : (i += 1) {
            j = 0;

            while (j < 4) : (j += 1) {
                k = 0;

                var sum: f32 = 0;

                while (k < 4) : (k += 1) {
                    sum += a.at(i, k) * b.at(k, j);
                }

                res.set(i, j, sum);
            }
        }

        return res;
    }

    /// returns the sum of of an m4 with another m4
    pub fn summ(a: m4, b: m4) m4 {
        var res = m4.init();

        var i: u16 = 0;
        var j: u16 = 0;

        while (i < 4) : (i += 1) {
            j = 0;

            while (j < 4) : (j += 1) {
                res.set(i, j, a.at(i, j) + b.at(i, j));
            }
        }

        return res;
    }

    /// returns the sub of of an m4 with another m4
    pub fn subm(a: m4, b: m4) m4 {
        var res = m4.init();

        var i: u16 = 0;
        var j: u16 = 0;

        while (i < 4) : (i += 1) {
            j = 0;

            while (j < 4) : (j += 1) {
                res.set(i, j, a.at(i, j) - b.at(i, j));
            }
        }

        return res;
    }

    /// returns the inverse of the provided matrix. if no inverse can be found it returns a m4(nan)
    pub fn inverse(a: m4) m4 {
        var t = a;

        const det2_01_01 = t.at(0, 0) * t.at(1, 1) - t.at(0, 1) * t.at(1, 0);
        const det2_01_02 = t.at(0, 0) * t.at(1, 2) - t.at(0, 2) * t.at(1, 0);
        const det2_01_03 = t.at(0, 0) * t.at(1, 3) - t.at(0, 3) * t.at(1, 0);
        const det2_01_12 = t.at(0, 1) * t.at(1, 2) - t.at(0, 2) * t.at(1, 1);
        const det2_01_13 = t.at(0, 1) * t.at(1, 3) - t.at(0, 3) * t.at(1, 1);
        const det2_01_23 = t.at(0, 2) * t.at(1, 3) - t.at(0, 3) * t.at(1, 2);

        const det3_201_012 = t.at(2, 0) * det2_01_12 - t.at(2, 1) * det2_01_02 + t.at(2, 2) * det2_01_01;
        const det3_201_013 = t.at(2, 0) * det2_01_13 - t.at(2, 1) * det2_01_03 + t.at(2, 3) * det2_01_01;
        const det3_201_023 = t.at(2, 0) * det2_01_23 - t.at(2, 2) * det2_01_03 + t.at(2, 3) * det2_01_02;
        const det3_201_123 = t.at(2, 1) * det2_01_23 - t.at(2, 2) * det2_01_13 + t.at(2, 3) * det2_01_12;

        const det = - det3_201_123 * t.at(3, 0) + det3_201_023 * t.at(3, 1) - det3_201_013 * t.at(3, 2) + det3_201_012 * t.at(3, 3);
        const invDet = 1 / det;

        const det2_03_01 = t.at(0, 0) * t.at(3, 1) - t.at(0, 1) * t.at(3, 0);
        const det2_03_02 = t.at(0, 0) * t.at(3, 2) - t.at(0, 2) * t.at(3, 0);
        const det2_03_03 = t.at(0, 0) * t.at(3, 3) - t.at(0, 3) * t.at(3, 0);
        const det2_03_12 = t.at(0, 1) * t.at(3, 2) - t.at(0, 2) * t.at(3, 1);
        const det2_03_13 = t.at(0, 1) * t.at(3, 3) - t.at(0, 3) * t.at(3, 1);
        const det2_03_23 = t.at(0, 2) * t.at(3, 3) - t.at(0, 3) * t.at(3, 2);
        const det2_13_01 = t.at(1, 0) * t.at(3, 1) - t.at(1, 1) * t.at(3, 0);
        const det2_13_02 = t.at(1, 0) * t.at(3, 2) - t.at(1, 2) * t.at(3, 0);
        const det2_13_03 = t.at(1, 0) * t.at(3, 3) - t.at(1, 3) * t.at(3, 0);
        const det2_13_12 = t.at(1, 1) * t.at(3, 2) - t.at(1, 2) * t.at(3, 1);
        const det2_13_13 = t.at(1, 1) * t.at(3, 3) - t.at(1, 3) * t.at(3, 1);
        const det2_13_23 = t.at(1, 2) * t.at(3, 3) - t.at(1, 3) * t.at(3, 2);

        const det3_203_012 = t.at(2, 0) * det2_03_12 - t.at(2, 1) * det2_03_02 + t.at(2, 2) * det2_03_01;
        const det3_203_013 = t.at(2, 0) * det2_03_13 - t.at(2, 1) * det2_03_03 + t.at(2, 3) * det2_03_01;
        const det3_203_023 = t.at(2, 0) * det2_03_23 - t.at(2, 2) * det2_03_03 + t.at(2, 3) * det2_03_02;
        const det3_203_123 = t.at(2, 1) * det2_03_23 - t.at(2, 2) * det2_03_13 + t.at(2, 3) * det2_03_12;

        const det3_213_012 = t.at(2, 0) * det2_13_12 - t.at(2, 1) * det2_13_02 + t.at(2, 2) * det2_13_01;
        const det3_213_013 = t.at(2, 0) * det2_13_13 - t.at(2, 1) * det2_13_03 + t.at(2, 3) * det2_13_01;
        const det3_213_023 = t.at(2, 0) * det2_13_23 - t.at(2, 2) * det2_13_03 + t.at(2, 3) * det2_13_02;
        const det3_213_123 = t.at(2, 1) * det2_13_23 - t.at(2, 2) * det2_13_13 + t.at(2, 3) * det2_13_12;

        const det3_301_012 = t.at(3, 0) * det2_01_12 - t.at(3, 1) * det2_01_02 + t.at(3, 2) * det2_01_01;
        const det3_301_013 = t.at(3, 0) * det2_01_13 - t.at(3, 1) * det2_01_03 + t.at(3, 3) * det2_01_01;
        const det3_301_023 = t.at(3, 0) * det2_01_23 - t.at(3, 2) * det2_01_03 + t.at(3, 3) * det2_01_02;
        const det3_301_123 = t.at(3, 1) * det2_01_23 - t.at(3, 2) * det2_01_13 + t.at(3, 3) * det2_01_12;

        var res = m4.init();

        res.set(0, 0, -det3_213_123 * invDet);
        res.set(1, 0, det3_213_023 * invDet);
        res.set(2, 0, -det3_213_013 * invDet);
        res.set(3, 0, det3_213_012 * invDet);

        res.set(0, 1, det3_203_123 * invDet);
        res.set(1, 1, -det3_203_023 * invDet);
        res.set(2, 1, det3_203_013 * invDet);
        res.set(3, 1, -det3_203_012 * invDet);

        res.set(0, 2, det3_301_123 * invDet);
        res.set(1, 2, -det3_301_023 * invDet);
        res.set(2, 2, det3_301_013 * invDet);
        res.set(3, 2, -det3_301_012 * invDet);

        res.set(0, 3, -det3_201_123 * invDet);
        res.set(1, 3, det3_201_023 * invDet);
        res.set(2, 3, -det3_201_013 * invDet);
        res.set(3, 3, det3_201_012 * invDet);

        return res;
    }
};

test "creating an m4" {
    const x = m4.init();

    testing.expect(x.at(0, 0) == 1);
    testing.expect(x.at(1, 1) == 1);
    testing.expect(x.at(2, 2) == 1);
    testing.expect(x.at(3, 3) == 1);
}

test "settings m4 values" {
    var x = m4.init();

    x.set(0, 2, 10);

    testing.expect(x.at(0, 2) == 10);
}

test "multiplying m4 with scalars" {
    const x = m4.init().muls(4);

    testing.expect(x.at(0, 0) == 4);
    testing.expect(x.at(1, 1) == 4);
    testing.expect(x.at(2, 2) == 4);
    testing.expect(x.at(3, 3) == 4);
}

test "multiplying m4 with v4" {
    const v = v4.init(1, 2, 3, 4);

    const x = m4.init().muls(2).mulv(v);

    testing.expect(x.x == 2);
    testing.expect(x.y == 4);
    testing.expect(x.z == 6);
    testing.expect(x.w == 8);
}

test "multiplying m4 with m4" {
    const a = m4.init().muls(2);
    const b = m4.init().muls(3);

    const x = a.mulm(b);

    testing.expect(x.at(0, 0) == 6);
    testing.expect(x.at(1, 1) == 6);
    testing.expect(x.at(2, 2) == 6);
    testing.expect(x.at(3, 3) == 6);
}

test "subtracting and summing two m4" {
    const a = m4.init().muls(2);
    const b = m4.init().muls(3);

    const sm = a.summ(b);

    testing.expect(sm.at(0, 0) == 5);
    testing.expect(sm.at(1, 1) == 5);
    testing.expect(sm.at(2, 2) == 5);
    testing.expect(sm.at(3, 3) == 5);

    const sb = a.subm(b);

    testing.expect(sb.at(0, 0) == -1);
    testing.expect(sb.at(1, 1) == -1);
    testing.expect(sb.at(2, 2) == -1);
    testing.expect(sb.at(3, 3) == -1);
}

test "scaling m4" {
    const x = m4.scaling(v4.init(0, 1, 0, 0));

    testing.expect(x.at(1, 1) == 1);
}

test "rotation m4" {
    const x = m4.rotation(45, v3.init(0, 1, 0));

    testing.expect(math.approxEq(f32, x.at(0, 0), 0.525323450, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(0, 1), 0, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(0, 2), 0.850902616, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 0), 0, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 1), 1, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 2), 0, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 0), -0.850902616, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 1), 0, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 2), 0.525323450, math.f32_epsilon));
}

test "translation m4" {
    const x = m4.translation(v3.init(1, 2, 3));

    testing.expect(x.at(0, 3) == 1);
    testing.expect(x.at(1, 3) == 2);
    testing.expect(x.at(2, 3) == 3);
}

test "look at m4" {
    const x = m4.lookAt(v3.init(0, 0, 0), v3.init(1, 1, 1), v3.init(0, 1, 0));

    testing.expect(math.approxEq(f32, x.at(0, 0), -0.707106769, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(0, 2), 0.707106769, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 0), -0.408248275, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 1), 0.816496551, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 2), -0.408248275, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 0), -0.577350258, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 1), -0.577350258, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 2), -0.577350258, math.f32_epsilon));
}

test "orthographic projection m4" {
    const x = m4.orthographic(0, 1280, 720, 0, 5, 10);

    testing.expect(math.approxEq(f32, x.at(0, 0), 0.00156250002, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(0, 3), -1, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 1), -0.00277777784, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 3), 1, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 2), -0.4, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 3), -3, math.f32_epsilon));
}

test "perspective projection m4" {
    const x = m4.perspective(1.57, 1.7, 0, 5);

    testing.expect(math.approxEq(f32, x.at(0, 0), 0.588703811, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(1, 1), 1.00079655, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(2, 2), -1, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.at(3, 2), -1, math.f32_epsilon));
}

test "inverse m4" {
    const x = m4.init().muls(5);

    const res = x.inverse();

    testing.expect(math.approxEq(f32, res.at(0, 0), 0.2, math.f32_epsilon));
    testing.expect(math.approxEq(f32, res.at(1, 1), 0.2, math.f32_epsilon));
    testing.expect(math.approxEq(f32, res.at(2, 2), 0.2, math.f32_epsilon));
    testing.expect(math.approxEq(f32, res.at(3, 3), 0.2, math.f32_epsilon));
}
