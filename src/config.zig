const sdl3 = @cImport({
    @cInclude("SDL3/SDL.h");
});
pub const TEXTURE_SIZE: c_int = 16;
pub const TEXTURE_ARRAY_SIZE: c_int = TEXTURE_SIZE * TEXTURE_SIZE;
pub const BACKGROUND_COLOR = sdl3.SDL_Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
