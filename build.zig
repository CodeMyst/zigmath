const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("zigmath", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var v2_tests = b.addTest("src/vector2.zig");
    v2_tests.setBuildMode(mode);

    var v3_tests = b.addTest("src/vector3.zig");
    v3_tests.setBuildMode(mode);

    var v4_tests = b.addTest("src/vector4.zig");
    v4_tests.setBuildMode(mode);

    var m4_tests = b.addTest("src/matrix4.zig");
    m4_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&v2_tests.step);
    test_step.dependOn(&v3_tests.step);
    test_step.dependOn(&v4_tests.step);
    test_step.dependOn(&m4_tests.step);
}
