const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const xcursor_dep = b.dependency("xcursor", .{});

    const x11_dep = b.dependency("x11", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const x11 = x11_dep.artifact("x11");

    const xorgproto_dep = b.dependency("xorgproto", .{
        .target = target,
        .optimize = optimize,
    });
    const xorgproto = xorgproto_dep.artifact("xorgproto");

    const xrender_dep = b.dependency("xrender", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const xrender = xrender_dep.artifact("xrender");

    const xfixes_dep = b.dependency("xfixes", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const xfixes = xfixes_dep.artifact("xfixes");

    const cursor_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = xcursor_dep.path("include/X11/Xcursor/Xcursor.h.in") },
        .include_path = "Xcursor.h",
    }, .{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = if (linkage == .dynamic) true else null,
    });
    mod.linkLibrary(x11);
    mod.linkLibrary(xorgproto);
    mod.linkLibrary(xrender);
    mod.linkLibrary(xfixes);
    mod.addConfigHeader(cursor_h);
    mod.addCSourceFiles(.{
        .root = xcursor_dep.path("src"),
        .files = &sources,
        .flags = &.{"-DHAVE_XFIXES"},
    });

    const lib = b.addLibrary(.{
        .name = "xcursor",
        .root_module = mod,
        .linkage = linkage,
    });
    lib.installHeader(cursor_h.getOutputFile(), "X11/Xcursor/Xcursor.h");
    b.installArtifact(lib);
}

const sources = .{
    "cursor.c",
    "display.c",
    "file.c",
    "library.c",
    "xlib.c",
};
