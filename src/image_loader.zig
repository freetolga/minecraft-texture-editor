const std = @import("std");
const zigimg = @import("zigimg");
const cube = @import("cube.zig").Cube;
const config = @import("config.zig");
const mte_errors = @import("errors.zig");
pub fn load_image_into_scene(cube_array: *[config.TEXTURE_ARRAY_SIZE]cube, path: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var image = try zigimg.Image.fromFilePath(allocator, path);
    const pixels = image.pixels.rgba32;
    defer image.deinit();

    for (0..pixels.len, 0..cube_array.len) |i, j| {
        cube_array[j].color.r = pixels[i].r;
        cube_array[j].color.g = pixels[i].g;
        cube_array[j].color.b = pixels[i].b;
        cube_array[j].color.a = pixels[i].a;
    }
}
pub fn save_image_from_scene(cube_array: *[config.TEXTURE_ARRAY_SIZE]cube, path: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var image = try zigimg.Image.create(allocator, config.TEXTURE_SIZE, config.TEXTURE_SIZE, zigimg.PixelFormat.rgba32);
    const pixels = image.pixels.rgba32;
    defer image.deinit();

    for (0..pixels.len, 0..cube_array.len) |i, j| {
        pixels[i].r = cube_array[j].color.r;
        pixels[i].g = cube_array[j].color.g;
        pixels[i].b = cube_array[j].color.b;
        pixels[i].a = cube_array[j].color.a;
    }

    try image.writeToFilePath(path, .{ .png = .{} });
}
