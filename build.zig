const std = @import("std");

pub fn build(b: *std.Build) void {
    const root_source_file = "main.zig";

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get the comphash dependency first
    const zh_pkg = b.dependency("comphash", .{ .target = target, .optimize = optimize });
    const zh_mod = zh_pkg.module("comphash");

    const ch_mod = b.addModule("comphash-bench", .{
        .root_source_file = b.path(root_source_file),
        .target = target,
        .optimize = optimize,
    });

    // Add the comphash import to the module
    ch_mod.addImport("comphash", zh_mod);

    _ = b.addLibrary(.{
        .name = "comphash-bench",
        .linkage = .static,
        .root_module = ch_mod,
    });

    const exe = b.addExecutable(.{
        .name = "comphash-bench",
        .root_module = ch_mod,
    });

    // The executable will inherit the import from ch_mod, but you can also add it explicitly if needed
    exe.root_module.addImport("comphash", zh_mod);
    // Install the executable
    b.installArtifact(exe);

    // Add a run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // Create a run step
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
