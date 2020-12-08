const testing = @import("std").testing;
const math = @import("std").math;

/// converts degrees to radians
pub inline fn rad(d: f32) f32 {
    return d * (math.pi / 180.0);
}

/// converts radians to degrees
pub inline fn deg(r: f32) f32 {
    return r * (180.0 / math.pi);
}

test "rad and deg" {
    testing.expect(deg(math.pi) == 180);
    testing.expect(rad(180) == math.pi);
}
