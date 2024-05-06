const std = @import("std");
const Godot = @import("godot");
const GDE = Godot.GDE;
const builtin = @import("builtin");
const GPA = std.heap.GeneralPurposeAllocator(.{});

fn initializeLevel(_: ?*anyopaque, p_level: GDE.GDExtensionInitializationLevel) callconv(.C) void {
    if (p_level != GDE.GDEXTENSION_INITIALIZATION_SCENE) {
        return;
    }

    const ExampleNode = @import("ExampleNode.zig");
    Godot.registerClass(ExampleNode);
}

fn deinitializeLevel(userdata: ?*anyopaque, p_level: GDE.GDExtensionInitializationLevel) callconv(.C) void {
    if (p_level != GDE.GDEXTENSION_INITIALIZATION_CORE) {
        return;
    }

    Godot.deinit();
    if (builtin.mode == .Debug) {
        var gpa = @as(*GPA, @ptrCast(@alignCast(userdata.?)));
        _ = gpa.deinit();
        std.heap.c_allocator.destroy(gpa);
    }
}

pub export fn my_extension_init(p_get_proc_address: GDE.GDExtensionInterfaceGetProcAddress, p_library: GDE.GDExtensionClassLibraryPtr, r_initialization: [*c]GDE.GDExtensionInitialization) callconv(.C) GDE.GDExtensionBool {
    r_initialization.*.initialize = initializeLevel;
    r_initialization.*.deinitialize = deinitializeLevel;
    r_initialization.*.minimum_initialization_level = GDE.GDEXTENSION_INITIALIZATION_SCENE;

    var allocator: std.mem.Allocator = undefined;
    if (builtin.mode == .Debug) {
        var gpa = std.heap.c_allocator.create(GPA) catch unreachable;
        gpa.* = GPA{};
        r_initialization.*.userdata = @ptrCast(@alignCast(gpa));
        allocator = gpa.allocator();
    } else {
        allocator = std.heap.c_allocator;
    }

    Godot.init(p_get_proc_address.?, p_library, allocator) catch unreachable;

    return 1;
}

const c = @cImport({
    @cInclude("dlfcn.h");
});

pub fn main() !void {
    const lib_path: [*:0]const u8 = "libgodot.dylib";
    const RTLD_LAZY = 1;
    const lib = c.dlopen(lib_path, RTLD_LAZY) orelse {
        std.log.warn("Failed to open {s}\n", .{lib_path});
        return;
    };
    defer _ = c.dlclose(lib);

    const symbol = c.dlsym(lib, "gdextension_create_godot_instance") orelse {
        std.log.warn("Failed to find symbol 'gdextension_create_godot_instance'\n", .{});
        return;
    };

    const ArgvType = [*:null]const ?[*:0]const u8;
    const InitFuncType = *const fn (GDE.GDExtensionInterfaceGetProcAddress, GDE.GDExtensionClassLibraryPtr, [*c]GDE.GDExtensionInitialization) callconv(.C) GDE.GDExtensionBool;
    const argv: ArgvType = &.{ "", "--path", "./project" };
    const create_godot_instance = @as(*const fn (c_int, ArgvType, InitFuncType) GDE.GDExtensionObjectPtr, @alignCast(@ptrCast(symbol)));
    const inst = create_godot_instance(3, argv, &my_extension_init);
    const gi: *Godot.GodotInstance = @ptrCast(@alignCast(Godot.getObjectInstanceBinding(inst)));
    _ = gi.start();
    while (!gi.iteration()) {}
    gi.shutdown();
}
