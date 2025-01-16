const sdl3 = @cImport({
    @cInclude("SDL3/SDL.h");
});
pub const Cube = struct {
    rect: sdl3.SDL_FRect,
    color: sdl3.SDL_Color,
};
