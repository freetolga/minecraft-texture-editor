const std = @import("std");
const sdl3 = @cImport({
    @cInclude("SDL3/SDL.h");
});
const colors = @import("colors.zig");
const mte_errors = @import("errors.zig");
const Cube = @import("cube.zig").Cube;
const config = @import("config.zig");
const image_loader = @import("image_loader.zig");

// the 9 color slots
var color1 = colors.color1;
var color2 = colors.color2;
var color3 = colors.color3;
var color4 = colors.color4;
var color5 = colors.color5;
var color6 = colors.color6;
var color7 = colors.color7;
var color8 = colors.color8;
var color9 = colors.color9;

pub fn main() !void {
    // resolve image paths
    const allocator = std.heap.c_allocator;
    var args_iter = try std.process.argsWithAllocator(allocator);
    _ = args_iter.skip();
    const load_path = if (args_iter.next()) |p| p else "grass_block.png";
    const save_path = if (args_iter.next()) |p| p else "grass_block_new.png";
    // load window
    var SCALING_FACTOR: c_int = 10;
    var WINDOW_X: c_int = config.TEXTURE_SIZE * SCALING_FACTOR;
    var WINDOW_Y: c_int = WINDOW_X;
    const init_flags: c_uint = sdl3.SDL_INIT_VIDEO;
    if (!sdl3.SDL_Init(init_flags)) {
        std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
        return mte_errors.sdl_error.SDLInitError;
    }
    defer sdl3.SDL_QuitSubSystem(init_flags);

    const window_flags = sdl3.SDL_WINDOW_RESIZABLE;
    var window: ?*sdl3.SDL_Window = undefined;
    var renderer: ?*sdl3.SDL_Renderer = undefined;
    if (!sdl3.SDL_CreateWindowAndRenderer("Minecraft Texture Editor", WINDOW_X, WINDOW_Y, window_flags, &window, &renderer) or window == null or renderer == null) {
        std.debug.print("{s}", .{sdl3.SDL_GetError()});
        return mte_errors.sdl_error.SDLWindowCreateError;
    }
    defer sdl3.SDL_DestroyWindow(window);
    defer sdl3.SDL_DestroyRenderer(renderer);
    if (!sdl3.SDL_ShowWindow(window)) {
        std.debug.print("{s}", .{sdl3.SDL_GetError()});
        return mte_errors.sdl_error.SDLShowWindowError;
    }

    // store the scene as an array of cubes

    var cubes: [config.TEXTURE_ARRAY_SIZE]Cube = undefined;
    for (0..config.TEXTURE_ARRAY_SIZE) |i| {
        cubes[i] = Cube{
            .rect = sdl3.SDL_FRect{
                .x = @as(f32, @floatFromInt((i % config.TEXTURE_SIZE) * @as(usize, @intCast(SCALING_FACTOR)))),
                // increment for every TEXTURE_SIZE step of i
                .y = @as(f32, @floatFromInt(@divFloor(i, config.TEXTURE_SIZE) * @as(usize, @intCast(SCALING_FACTOR)))),
                .w = @as(f32, @floatFromInt(SCALING_FACTOR)),
                .h = @as(f32, @floatFromInt(SCALING_FACTOR)),
            },
            .color = config.BACKGROUND_COLOR,
        };
    }
    // variables to store mouse position
    var x: f32 = 0;
    var y: f32 = 0;
    var color: sdl3.SDL_Color = config.BACKGROUND_COLOR;

    var event: sdl3.SDL_Event = undefined;
    var quit: bool = false;
    while (!quit) {
        if (sdl3.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl3.SDL_EVENT_QUIT => {
                    quit = true;
                    break;
                },
                sdl3.SDL_EVENT_MOUSE_MOTION => {
                    x = event.motion.x;
                    y = event.motion.y;
                },
                sdl3.SDL_EVENT_KEY_DOWN => {
                    switch (event.key.key) {
                        // red
                        sdl3.SDLK_1 => {
                            color = color1;
                        },
                        // orange
                        sdl3.SDLK_2 => {
                            color = color2;
                        },
                        // yellow
                        sdl3.SDLK_3 => {
                            color = color3;
                        },
                        // green
                        sdl3.SDLK_4 => {
                            color = color4;
                        },
                        // blue
                        sdl3.SDLK_5 => {
                            color = color5;
                        },
                        // purple
                        sdl3.SDLK_6 => {
                            color = color6;
                        },
                        sdl3.SDLK_7 => {
                            color = color7;
                        },
                        sdl3.SDLK_8 => {
                            color = color8;
                        },
                        sdl3.SDLK_9 => {
                            color = color9;
                        },
                        // place a cube by coloring the one over the mouse cursor
                        sdl3.SDLK_SPACE => {
                            const idx: usize = @as(usize, @intCast(@divFloor(@as(usize, @intFromFloat(x)), @as(usize, @intCast(SCALING_FACTOR))) + @divFloor(@as(usize, @intFromFloat(y)), @as(usize, @intCast(SCALING_FACTOR))) * config.TEXTURE_SIZE));
                            cubes[idx].color = color;
                        },
                        // reset the scene
                        sdl3.SDLK_R => {
                            for (0..config.TEXTURE_ARRAY_SIZE) |i| {
                                cubes[i].color = config.BACKGROUND_COLOR;
                            }
                        },
                        // increase screen size, not working yet!
                        sdl3.SDLK_PLUS => {
                            SCALING_FACTOR += 1;
                            WINDOW_X = config.TEXTURE_SIZE * SCALING_FACTOR;
                            WINDOW_Y = WINDOW_X;
                            if (!sdl3.SDL_SetWindowSize(window, WINDOW_X, WINDOW_Y)) {
                                std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
                                return mte_errors.sdl_error.SDLWindowResizeError;
                            }
                        },
                        sdl3.SDLK_L => {
                            try image_loader.load_image_into_scene(&cubes, load_path);
                        },
                        sdl3.SDLK_S => {
                            try image_loader.save_image_from_scene(&cubes, save_path);
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        // https://wiki.libsdl.org/SDL2/SDL_RenderPresent
        // 1) clear the back buffer
        try clear_scene(renderer, config.BACKGROUND_COLOR);
        // 2) fill the back buffer
        for (cubes) |cube| {
            if (!sdl3.SDL_SetRenderDrawColor(renderer, cube.color.r, cube.color.g, cube.color.b, cube.color.a)) {
                std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
                return mte_errors.sdl_error.SDLSetRenderDrawColorError;
            }
            if (!sdl3.SDL_RenderFillRect(renderer, &cube.rect)) {
                std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
                return mte_errors.sdl_error.SDLRenderFillRectError;
            }
        }
        // 3) call RenderPresent
        if (!sdl3.SDL_RenderPresent(renderer)) {
            std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
            return mte_errors.sdl_error.SDLRenderPresentError;
        }
        // 4) clear the back buffer again so that it does not flicker
        try clear_scene(renderer, config.BACKGROUND_COLOR);
    }
    std.debug.print("Quitting the game\n", .{});
}

fn clear_scene(renderer: ?*sdl3.SDL_Renderer, background_color: sdl3.SDL_Color) !void {
    if (!sdl3.SDL_SetRenderDrawColor(renderer, background_color.r, background_color.g, background_color.b, background_color.a)) {
        std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
        return mte_errors.sdl_error.SDLRenderClearError;
    }
    if (!sdl3.SDL_RenderClear(renderer)) {
        std.debug.print("{s}\n", .{sdl3.SDL_GetError()});
        return mte_errors.sdl_error.SDLRenderClearError;
    }
}
