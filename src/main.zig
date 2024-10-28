const std = @import("std");
const sdl2 = @cImport({
    @cInclude("SDL2/SDL.h");
});
const colors = @import("colors.zig");
const sdl_error = error{
    SDLInitError,
    SDLWindowCreateError,
    SDLSurfaceCreationError,
    SDLRendererCreationError,
    SDLSurfaceUpdateError,
    SDLRenderPresentError,
    SDLRenderFillRectError,
    SDLSetRenderDrawColorError,
    SDLRenderClearError,
    SDLRendererSetVSyncError,
};
const TEXTURE_SIZE: c_int = 16;
const TEXTURE_ARRAY_SIZE: c_int = TEXTURE_SIZE * TEXTURE_SIZE;
const BACKGROUND_COLOR = sdl2.SDL_Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
const Cube = struct {
    rect: sdl2.SDL_Rect,
    color: sdl2.SDL_Color,
};

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
    var SCALING_FACTOR: c_int = 10;
    var WINDOW_X: c_int = TEXTURE_SIZE * SCALING_FACTOR;
    var WINDOW_Y: c_int = WINDOW_X;
    const init_flags: c_uint = sdl2.SDL_INIT_EVERYTHING;
    if (sdl2.SDL_Init(init_flags) != 0) {
        std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
        return sdl_error.SDLInitError;
    }
    defer sdl2.SDL_Quit();

    const window_flags = sdl2.SDL_WINDOW_SHOWN;
    const window = sdl2.SDL_CreateWindow("Minecraft Texture Editor", sdl2.SDL_WINDOWPOS_UNDEFINED, sdl2.SDL_WINDOWPOS_UNDEFINED, WINDOW_X, WINDOW_Y, window_flags);
    if (window == null) {
        std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
        return sdl_error.SDLWindowCreateError;
    }
    defer sdl2.SDL_DestroyWindow(window);
    sdl2.SDL_ShowWindow(window);
    const renderer = sdl2.SDL_CreateRenderer(window, -1, sdl2.SDL_RENDERER_ACCELERATED | sdl2.SDL_RENDERER_PRESENTVSYNC);
    if (renderer == null) {
        return sdl_error.SDLRendererCreationError;
    }
    defer sdl2.SDL_DestroyRenderer(renderer);
    var event: sdl2.SDL_Event = undefined;
    var quit: bool = false;

    // store the scene as an array of cubes

    var cubes: [TEXTURE_ARRAY_SIZE]Cube = undefined;
    for (0..TEXTURE_ARRAY_SIZE) |i| {
        cubes[i] = Cube{
            .rect = sdl2.SDL_Rect{
                .x = @as(c_int, @intCast(i % 16)) * SCALING_FACTOR,
                // increment for every TEXTURE_SIZE step of i
                .y = @as(c_int, @intCast(@divTrunc(i, TEXTURE_SIZE))) * SCALING_FACTOR,
                .w = SCALING_FACTOR,
                .h = SCALING_FACTOR,
            },
            .color = BACKGROUND_COLOR,
        };
    }
    // variables to store mouse position
    var x: i32 = 0;
    var y: i32 = 0;
    var color: sdl2.SDL_Color = BACKGROUND_COLOR;

    while (!quit) {
        while (sdl2.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl2.SDL_QUIT => {
                    quit = true;
                    break;
                },
                sdl2.SDL_MOUSEMOTION => {
                    x = event.motion.x;
                    y = event.motion.y;
                },
                sdl2.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        // red
                        sdl2.SDLK_1 => {
                            color = color1;
                        },
                        // orange
                        sdl2.SDLK_2 => {
                            color = color2;
                        },
                        // yellow
                        sdl2.SDLK_3 => {
                            color = color3;
                        },
                        // green
                        sdl2.SDLK_4 => {
                            color = color4;
                        },
                        // blue
                        sdl2.SDLK_5 => {
                            color = color5;
                        },
                        // purple
                        sdl2.SDLK_6 => {
                            color = color6;
                        },
                        sdl2.SDLK_7 => {
                            color = color7;
                        },
                        sdl2.SDLK_8 => {
                            color = color8;
                        },
                        sdl2.SDLK_9 => {
                            color = color9;
                        },
                        // place a cube by coloring the one over the mouse cursor
                        sdl2.SDLK_SPACE => {
                            const idx: usize = @as(usize, @intCast(@divFloor(x, SCALING_FACTOR) + @divFloor(y, SCALING_FACTOR) * TEXTURE_SIZE));
                            cubes[idx].color = color;
                        },
                        // reset the scene
                        sdl2.SDLK_r => {
                            for (0..TEXTURE_ARRAY_SIZE) |i| {
                                cubes[i].color = BACKGROUND_COLOR;
                            }
                        },
                        // increase screen size, not working yet!
                        sdl2.SDLK_PLUS => {
                            SCALING_FACTOR += 1;
                            WINDOW_X = TEXTURE_SIZE * SCALING_FACTOR;
                            WINDOW_Y = WINDOW_X;
                            sdl2.SDL_SetWindowSize(window, WINDOW_X, WINDOW_Y);
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        // https://wiki.libsdl.org/SDL2/SDL_RenderPresent
        // 1) clear the back buffer
        if (sdl2.SDL_SetRenderDrawColor(renderer, BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b, BACKGROUND_COLOR.a) != 0) {
            std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
            return sdl_error.SDLInitError;
        }
        if (sdl2.SDL_RenderClear(renderer) != 0) {
            std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
            return sdl_error.SDLInitError;
        }
        // 2) fill the back buffer
        for (cubes) |cube| {
            if (sdl2.SDL_SetRenderDrawColor(renderer, cube.color.r, cube.color.g, cube.color.b, cube.color.a) != 0) {
                std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
                return sdl_error.SDLInitError;
            }
            if (sdl2.SDL_RenderFillRect(renderer, &cube.rect) != 0) {
                std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
                return sdl_error.SDLInitError;
            }
        }
        // 3) call RenderPresent
        sdl2.SDL_RenderPresent(renderer);
        // 4) clear the back buffer again so that it does not flicker
        if (sdl2.SDL_SetRenderDrawColor(renderer, BACKGROUND_COLOR.r, BACKGROUND_COLOR.g, BACKGROUND_COLOR.b, BACKGROUND_COLOR.a) != 0) {
            std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
            return sdl_error.SDLInitError;
        }
        if (sdl2.SDL_RenderClear(renderer) != 0) {
            std.debug.print("{s}\n", .{sdl2.SDL_GetError()});
            return sdl_error.SDLInitError;
        }
    }
    std.debug.print("Quitting the game\n", .{});
}
