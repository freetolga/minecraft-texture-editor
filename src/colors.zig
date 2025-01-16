const sdl3 = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const color1 = sdl3.SDL_Color{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 255,
};
pub const color2 = sdl3.SDL_Color{
    .r = 255,
    .g = 127,
    .b = 0,
    .a = 255,
};
pub const color3 = sdl3.SDL_Color{
    .r = 255,
    .g = 255,
    .b = 0,
    .a = 255,
};
pub const color4 = sdl3.SDL_Color{
    .r = 0,
    .g = 255,
    .b = 0,
    .a = 255,
};
pub const color5 = sdl3.SDL_Color{
    .r = 0,
    .g = 0,
    .b = 255,
    .a = 255,
};
pub const color6 = sdl3.SDL_Color{
    .r = 255,
    .g = 0,
    .b = 255,
    .a = 255,
};
pub const color7 = sdl3.SDL_Color{
    .r = 0,
    .g = 0,
    .b = 0,
    .a = 255,
};
pub const color8 = sdl3.SDL_Color{
    .r = 0,
    .g = 0,
    .b = 0,
    .a = 255,
};
pub const color9 = sdl3.SDL_Color{
    .r = 0,
    .g = 0,
    .b = 0,
    .a = 255,
};
