pub const sdl_error = error{
    SDLInitError,
    SDLWindowCreateError,
    SDLShowWindowError,
    SDLSurfaceCreationError,
    SDLRendererCreationError,
    SDLSurfaceUpdateError,
    SDLRenderPresentError,
    SDLRenderFillRectError,
    SDLSetRenderDrawColorError,
    SDLRenderClearError,
    SDLRendererSetVSyncError,
    SDLWindowResizeError,
};

pub const image_error = error{
    ImageLoadingError,
};
pub const arg_error = error{
    ArgumentParsingError,
};
