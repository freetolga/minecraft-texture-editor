const std = @import("std");
const cube = @import("cube.zig").Cube;
const config = @import("config.zig");
const mte_errors = @import("errors.zig");

pub fn draw_0(scene: [config.TEXTURE_ARRAY_SIZE]cube) !void {
    _ = scene;
}
