const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("zigmath", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var v2_tests = b.addTest("src/vector2.zig");
    v2_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&v2_tests.step);
}
