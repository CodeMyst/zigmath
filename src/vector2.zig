const testing = @import("std").testing;
const math = @import("std").math;

pub const v2 = struct {
    x: f32,
    y: f32,

    /// initializes a v2 with x and y
    pub fn init(x: f32, y: f32) v2 {
        return v2 {
            .x = x,
            .y = y,
        };
    }

    /// returns the x and y of the v2 as a [2]f32 array.
    /// to be used to pass to other stuff like opengl.
    pub fn arr(v: v2) [2]f32 {
        return .{v.x, v.y};
    }

    /// returns the length/magnitude of the vector
    pub fn len(v: v2) f32 {
        var sum: f32 = 0;
        sum += v.x * v.x;
        sum += v.y * v.y;
        return math.sqrt(sum);
    }

    /// returns the normalized vector
    pub fn normalized(v: v2) v2 {
        const l = v.len();

        if (l == 0) {
            return v2.init(0, 0);
        }

        return divs(v, l);
    }

    /// returns the dot product of two v2
    pub fn dot(a: v2, b: v2) f32 {
        var res: f32 = 0;
        res += a.x * b.x;
        res += a.y * b.y;
        return res;
    }

    /// returns the negated vector
    pub fn neg(v: v2) v2 {
        return v2.init(-v.x, -v.y);
    }

    /// divides the v2 with a scalar
    pub fn divs(v: v2, s: f32) v2 {
        return v2.init(v.x / s, v.y / s);
    }

    /// multiplies the v2 with a scalar
    pub fn muls(v: v2, s: f32) v2 {
        return v2.init(v.x * s, v.y * s);
    }

    /// sums the v2 with a scalar
    pub fn sums(v: v2, s: f32) v2 {
        return v2.init(v.x + s, v.y + s);
    }

    /// subtracts the v2 from a scalar
    pub fn subs(v: v2, s: f32) v2 {
        return v2.init(v.x - s, v.y - s);
    }

    /// sums the v2 with another v2
    pub fn sumv(a: v2, b: v2) v2 {
        return v2.init(a.x + b.x, a.y + b.y);
    }

    /// subtracts the v2 from another v2
    pub fn subv(a: v2, b: v2) v2 {
        return v2.init(a.x - b.x, a.y - b.y);
    }
};

test "creating a v2" {
    const x = v2.init(4, 8);

    testing.expect(x.x == 4);
    testing.expect(x.y == 8);
    testing.expect(x.arr()[0] == 4);
    testing.expect(x.arr()[1] == 8);
}

test "v2 length" {
    const x = v2.init(4, 8);

    testing.expect(math.approxEq(f32, x.len(), 8.94427190999916, math.f32_epsilon));
}

test "v2 operation" {
    const x = v2.init(4, 8);
    const y = v2.init(1, 3);
    var res = v2.divs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 4);

    res = v2.muls(x, 2);

    testing.expect(res.x == 8);
    testing.expect(res.y == 16);

    res = v2.neg(x);

    testing.expect(res.x == -4);
    testing.expect(res.y == -8);

    res = v2.sums(x, 2);

    testing.expect(res.x == 6);
    testing.expect(res.y == 10);

    res = v2.subs(x, 2);

    testing.expect(res.x == 2);
    testing.expect(res.y == 6);

    res = v2.sumv(x, y);

    testing.expect(res.x == 5);
    testing.expect(res.y == 11);

    res = v2.subv(x, y);

    testing.expect(res.x == 3);
    testing.expect(res.y == 5);
}

test "v2 normalized" {
    const a = v2.init(4, 8);
    const x = v2.normalized(a);

    testing.expect(math.approxEq(f32, x.x, 0.4472135954999579, math.f32_epsilon));
    testing.expect(math.approxEq(f32, x.y, 0.8944271909999159, math.f32_epsilon));
}

test "v2 dot" {
    const x = v2.init(4, 8);
    const y = v2.init(1, 3);
    const res = v2.dot(x, y);

    testing.expect(res == 28);
}
