const math = @import("std").math;

/// converts degrees to radians
pub inline fn rad(d: f32) f32 {
    return d * (math.pi / 180);
}

/// converts radians to degrees
pub inline fn deg(r: f32) f32 {
    return r * (180 / math.pi);
}
