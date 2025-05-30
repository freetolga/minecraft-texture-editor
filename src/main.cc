#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_oldnames.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_video.h>
#include <expected>
#include <iterator>
#include <memory>
#include <print>

namespace mte {

enum class SDLErrors {
  SDLInitError,
  SDLWindowCreateError,
  SDLRendererCreateError,
  SDLSetRenderDrawColorError,
  SDLRenderPresentError,
  SDLRenderClearError,
  SDLSetRenderVsyncError,
};

// copy pasted from
// https://stackoverflow.com/questions/24251747/smart-pointers-with-sdl
struct sdl_deleter {
  inline void operator()(SDL_Window *p) const { SDL_DestroyWindow(p); }
  inline void operator()(SDL_Renderer *p) const { SDL_DestroyRenderer(p); }
  inline void operator()(SDL_Texture *p) const { SDL_DestroyTexture(p); }
};

struct SDLRendererWindow {
public:
  std::unique_ptr<SDL_Renderer, sdl_deleter> renderer;
  std::unique_ptr<SDL_Window, sdl_deleter> window;
  SDLRendererWindow(const char *title, int width, int height,
                     SDL_WindowFlags window_flags) {
    SDL_Renderer *renderer_tmp;
    SDL_Window *window_tmp;
    if (!SDL_CreateWindowAndRenderer(title, width, height, window_flags,
                                     &window_tmp, &renderer_tmp)) {
        std::println("Failed to initialize SDL! {}", SDL_GetError());
        std::terminate();
    } else {
        renderer.reset(renderer_tmp);
        window.reset(window_tmp);
    }
  }
};

struct SDLInitializer {
  uint32_t subsystems;

public:
    explicit SDLInitializer(uint32_t subsystems_dummy) { if(SDL_Init(subsystems_dummy)) this->subsystems = subsystems_dummy; else std::abort(); }
    ~SDLInitializer() { SDL_QuitSubSystem(this->subsystems); }
};

} // namespace mte

struct rect_demo {
private:
  SDL_FRect rect;
  SDL_Color color;

public:
  auto set_my_color(SDL_Renderer *renderer) -> bool {
    return SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
  }
  auto draw_myself(SDL_Renderer *renderer) -> bool {
    return set_my_color(renderer) && SDL_RenderFillRect(renderer, &rect);
  }
  rect_demo(SDL_FRect rect, SDL_Color color) {
    this->rect = rect;
    this->color = color;
  }
};

auto main(int argc, char **argv) -> int {
    auto state = mte::SDLRendererWindow("test", 600, 600, SDL_WINDOW_RESIZABLE);
    auto rect1 = rect_demo({.x = 10, .y = 10, .w = 10, .h = 10},{.r = 10, .g = 0, .b = 255, .a = 0});
    rect1.draw_myself(state.renderer.get());
    SDL_ShowWindow(state.window.get());
    for(SDL_Event e; e.type != SDL_EVENT_QUIT ;SDL_PollEvent(&e) ) {}
    return 0;
}
