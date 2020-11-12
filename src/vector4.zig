const testing = @import("std").testing;
const math = @import("std").math;

pub const v4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    /// initializes a v4 with x, y, z and w
    pub fn init(x: f32, y: f32, z: f32, w: f32) v4 {
        return v4 {
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };
    }

    /// returns the component from an index
    pub fn at(v: v4, i: u16) f32 {
        return switch (i) {
            0 => v.x,
            1 => v.y,
            2 => v.z,
            3 => v.w,
            else => @panic("invalid index value provided when accessing a v4 index"),
        };
    }

    /// sets the component from an index
    pub fn set(v: *v4, i: u16, val: f32) void {
        switch (i) {
            0 => v.x = val,
            1 => v.y = val,
            2 => v.z = val,
            3 => v.w = val,
            else => @panic("invalid index value provided when accessing a v4 index"),
        }
    }

    /// returns the x, y, z and w of the v4 as a [4]f32 array.
    /// to be used to pass to other stuff like opengl.
    pub fn arr(v: v4) [4]f32 {
        return .{v.x, v.y, v.z, v.w};
    }

    /// returns the length/magnitude of the vector
    pub fn len(v: v4) f32 {
        var sum: f32 = 0;
        sum += v.x * v.x;
        sum += v.y * v.y;
        sum += v.z * v.z;
        sum += v.w * v.w;
        return math.sqrt(sum);
    }

    /// returns the normalized vector
    pub fn normalized(v: v4) v4 {
        const l = v.len();

        if (l == 0) {
            return v4.init(0, 0, 0, 0);
        }

        return divs(v, l);
    }

    /// returns the dot product of two v4
    pub fn dot(a: v4, b: v4) f32 {
        var res: f32 = 0;
        res += a.x * b.x;
        res += a.y * b.y;
        res += a.z * b.z;
        res += a.w * b.w;
        return res;
    }

    /// returns the negated vector
    pub fn neg(v: v4) v4 {
        return v4.init(-v.x, -v.y, -v.z, -v.w);
    }

    /// divides the v4 with a scalar
    pub fn divs(v: v4, s: f32) v4 {
        return v4.init(v.x / s, v.y / s, v.z / s, v.w / s);
    }

    /// multiplies the v4 with a scalar
    pub fn muls(v: v4, s: f32) v4 {
        return v4.init(v.x * s, v.y * s, v.z * s, v.w * s);
    }

    /// sums the v4 with a scalar
    pub fn sums(v: v4, s: f32) v4 {
        return v4.init(v.x + s, v.y + s, v.z + s, v.w + s);
    }

    /// subtracts the v4 from a scalar
    pub fn subs(v: v4, s: f32) v4 {
        return v4.init(v.x - s, v.y - s, v.z - s, v.w - s);
    }

    /// sums the v4 with another v4
    pub fn sumv(a: v4, b: v4) v4 {
        return v4.init(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }

    /// subtracts the v4 from another v4
    pub fn subv(a: v4, b: v4) v4 {
        return v4.init(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }
};

test "creating a v4" {
    const x = v4.init(4, 8, 2, 6);

    testing.expect(x.x == 4);
    testing.expect(x.y == 8);
    testing.expect(x.z == 2);
    testing.expect(x.w == 6);
    testing.expect(x.at(0) == 4);
    testing.expect(x.at(1) == 8);
    testing.expect(x.at(2) == 2);
    testing.expect(x.at(3) == 6);
    testing.expect(x.arr()[0] == 4);
    testing.expect(x.arr()[1] == 8);
    testing.expect(x.arr()[2] == 2);
    testing.expect(x.arr()[3] == 6);
}

test "v4 length" {
    const x = v4.init(4, 8, 2, 6);

    testing.expect(math.approxEq(f32, x.len(), 10.95445115010332226914, math.f32_epsilon));
}

test "v4 operation" {
    const x = v4.init(4, 8, 2, 6);
    const y = v4.init(1, 3, 5, 7);

    var res = v4.divs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 4);
    testing.expect(res.z == 1);
    testing.expect(res.w == 3);

    res = v4.muls(x, 2);

    testing.expect(res.x == 8);
    testing.expect(res.y == 16);
    testing.expect(res.z == 4);
    testing.expect(res.w == 12);

    res = v4.neg(x);

    testing.expect(res.x == -4);
    testing.expect(res.y == -8);
    testing.expect(res.z == -2);
    testing.expect(res.w == -6);

    res = v4.sums(x, 2);

    testing.expect(res.x == 6);
    testing.expect(res.y == 10);
    testing.expect(res.z == 4);
    testing.expect(res.w == 8);

    res = v4.subs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 6);
    testing.expect(res.z == 0);
    testing.expect(res.w == 4);

    res = v4.sumv(x, y);

    testing.expect(res.x == 5);
    testing.expect(res.y == 11);
    testing.expect(res.z == 7);
    testing.expect(res.w == 13);

    res = v4.subv(x, y);

    testing.expect(res.x == 3);
    testing.expect(res.y == 5);
    testing.expect(res.z == -3);
    testing.expect(res.w == -1);
}

test "v4 normalized" {
    const a = v4.init(4, 8, 2, 6);
    const x = v4.normalized(a);

    testing.expect(math.approxEq(f32, x.x, 0.3651483716701107423, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.y, 0.73029674334022148461, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.z, 0.18257418583505537115, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.w, 0.54772255750516611346, math.f32_epsilon));
}

test "v4 dot" {
    const x = v4.init(4, 8, 2, 6);
    const y = v4.init(1, 3, 5, 7);
    const res = v4.dot(x, y);

    testing.expect(res == 80);
}
