const math = @import("std").math;

/// converts degrees to radians
pub inline fn rad(deg: f32) f32 {
    return deg * (math.pi / 180);
}

/// converts radians to degrees
pub inline fn deg(rad: f32) f32 {
    return rad * (180 / math.pi);
}
