const testing = @import("std").testing;
const math = @import("std").math;

pub const v3 = struct {
    x: f32,
    y: f32,
    z: f32,

    /// initializes a v2 with x and y
    pub fn init(x: f32, y: f32, z: f32) v3 {
        return v3 {
            .x = x,
            .y = y,
            .z = z,
        };
    }

    /// returns the x, y and z of the v3 as a [3]f32 array.
    /// to be used to pass to other stuff like opengl.
    pub fn arr(v: v3) [3]f32 {
        return .{v.x, v.y, v.z};
    }

    /// returns the length/magnitude of the vector
    pub fn len(v: v3) f32 {
        var sum: f32 = 0;
        sum += v.x * v.x;
        sum += v.y * v.y;
        sum += v.z * v.z;
        return math.sqrt(sum);
    }

    /// returns the normalized vector
    pub fn normalized(v: v3) v3 {
        const l = v.len();

        if (l == 0) {
            return v3.init(0, 0, 0);
        }

        return divs(v, l);
    }

    /// returns the dot product of two v3
    pub fn dot(a: v3, b: v3) f32 {
        var res: f32 = 0;
        res += a.x * b.x;
        res += a.y * b.y;
        res += a.z * b.z;
        return res;
    }

    /// returns the cross product of two v3
    pub fn cross(a: v3, b: v3) v3 {
        return v3.init(a.y * b.z - a.z * b.y,
                       a.z * b.x - a.x * b.z,
                       a.x * b.y - a.y * b.x);
    }

    /// returns the negated vector
    pub fn neg(v: v3) v3 {
        return v3.init(-v.x, -v.y, -v.z);
    }

    /// divides the v3 with a scalar
    pub fn divs(v: v3, s: f32) v3 {
        return v3.init(v.x / s, v.y / s, v.z / s);
    }

    /// multiplies the v3 with a scalar
    pub fn muls(v: v3, s: f32) v3 {
        return v3.init(v.x * s, v.y * s, v.z * s);
    }

    /// sums the v2 with a scalar
    pub fn sums(v: v3, s: f32) v3 {
        return v3.init(v.x + s, v.y + s, v.z + s);
    }

    /// subtracts the v3 from a scalar
    pub fn subs(v: v3, s: f32) v3 {
        return v3.init(v.x - s, v.y - s, v.z - s);
    }

    /// sums the v3 with another v3
    pub fn sumv(a: v3, b: v3) v3 {
        return v3.init(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    /// subtracts the v3 from another v3
    pub fn subv(a: v3, b: v3) v3 {
        return v3.init(a.x - b.x, a.y - b.y, a.z - b.z);
    }
};

test "creating a v3" {
    const x = v3.init(4, 8, 2);

    testing.expect(x.x == 4);
    testing.expect(x.y == 8);
    testing.expect(x.z == 2);
    testing.expect(x.arr()[0] == 4);
    testing.expect(x.arr()[1] == 8);
    testing.expect(x.arr()[2] == 2);
}

test "v3 length" {
    const x = v3.init(4, 8, 2);

    testing.expect(math.approxEq(f32, x.len(), 9.16515138991168, math.f32_epsilon));
}

test "v3 operation" {
    const x = v3.init(4, 8, 2);
    const y = v3.init(1, 3, 5);
    var res = v3.divs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 4);
    testing.expect(res.z == 1);

    res = v3.muls(x, 2);

    testing.expect(res.x == 8);
    testing.expect(res.y == 16);
    testing.expect(res.z == 4);

    res = v3.neg(x);

    testing.expect(res.x == -4);
    testing.expect(res.y == -8);
    testing.expect(res.z == -2);

    res = v3.sums(x, 2);

    testing.expect(res.x == 6);
    testing.expect(res.y == 10);
    testing.expect(res.z == 4);

    res = v3.subs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 6);
    testing.expect(res.z == 0);

    res = v3.sumv(x, y);

    testing.expect(res.x == 5);
    testing.expect(res.y == 11);
    testing.expect(res.z == 7);

    res = v3.subv(x, y);

    testing.expect(res.x == 3);
    testing.expect(res.y == 5);
    testing.expect(res.z == -3);
}

test "v3 normalized" {
    const a = v3.init(4, 8, 2);
    const x = v3.normalized(a);

    testing.expect(math.approxEq(f32, x.x, 0.4364357804719848, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.y, 0.8728715609439696, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.z, 0.2182178902359924, math.f32_epsilon));
}

test "v3 dot" {
    const x = v3.init(4, 8, 2);
    const y = v3.init(1, 3, 5);
    const res = v3.dot(x, y);

    testing.expect(res == 38);
}

test "v3 cross" {
    const x = v3.init(4, 8, 2);
    const y = v3.init(1, 3, 5);
    const res = v3.cross(x, y);

    testing.expect(res.x == 34);
    testing.expect(res.y == -18);
    testing.expect(res.z == 4);
}
