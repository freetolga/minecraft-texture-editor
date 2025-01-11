#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_oldnames.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_video.h>
#include <print>

#ifndef defer
struct defer_dummy {};
template <class F> struct deferrer {
  F f;
  ~deferrer() { f(); }
};
template <class F> deferrer<F> operator*(defer_dummy, F f) { return {f}; }
#define DEFER_(LINE) zz_defer##LINE
#define DEFER(LINE) DEFER_(LINE)
#define defer auto DEFER(__LINE__) = defer_dummy{} *[&]()
#endif // defer

namespace mte {
auto error_print(const char *error) -> int {
  std::printf("Error: %s\n", error);
  return -1;
}
} // namespace mte
class Scene {
public:
  SDL_Color background_color;
  SDL_Window *window;
  SDL_Renderer *renderer;
  uint32_t subsystems;

  auto init_sdl() -> bool { return SDL_InitSubSystem(this->subsystems); }
  auto init_scene(const char *title, int width, int height,
                  SDL_WindowFlags window_flags) -> bool {
    return SDL_CreateWindowAndRenderer(title, width, height, window_flags,
                                       &window, &renderer) &&
           SDL_SetRenderVSync(renderer, 1);
  }
  void change_scene_color(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    background_color = SDL_Color{.r = r, .g = g, .b = b, .a = a};
  }
  auto apply_color(void) -> bool {
    return SDL_SetRenderDrawColor(this->renderer, background_color.r,
                                  background_color.g, background_color.b,
                                  background_color.a);
  }
  auto clear_scene(void) -> bool {
    return SDL_SetRenderDrawColor(this->renderer, 0, 0, 0, 0) &&
           SDL_RenderClear(renderer);
  }
  auto present(void) -> bool { return SDL_RenderPresent(this->renderer); }
  void destroy_scene(void) {
    SDL_DestroyRenderer(this->renderer);
    SDL_DestroyWindow(this->window);
  }
  void deinit_sdl(void) { SDL_QuitSubSystem(this->subsystems); }

  Scene(uint32_t subsystems) { this->subsystems = subsystems; }
};

class rect_demo {
public:
  SDL_FRect rect;
  SDL_Color color;
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
  if (argc < 2) {
    std::println("Usage: {} <Load Path> <Save Path>", argv[0]);
    return -1;
  }
  Scene myScene(SDL_INIT_VIDEO);
  if (!myScene.init_sdl()) {
    return mte::error_print(SDL_GetError());
  }

  defer { myScene.deinit_sdl(); };

  if (!myScene.init_scene("Minecraft Texture Editor", 256, 256,
                          SDL_WINDOW_RESIZABLE)) {
    return mte::error_print(SDL_GetError());
  }

  defer { myScene.destroy_scene(); };

  myScene.change_scene_color(0, 0, 0, 0);
  myScene.apply_color();

  rect_demo myrect(
    SDL_FRect {
      .x = 10.0,
      .y = 10.0,
      .w = 10.0,
      .h = 10.0,
    },

    SDL_Color {
      .r = 0,
      .g = 0,
      .b = 255,
      .a = 0,
    }
  );
  // game loop
  bool running = true;
  while (running) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
      switch (event.type) {
      case SDL_EVENT_QUIT:
        running = false;
        break;
      case SDL_EVENT_KEY_DOWN:
        switch (event.key.key) {
        case SDLK_UP:
          myrect.rect.y -= 10.0;
          break;
        case SDLK_DOWN:
          myrect.rect.y += 10.0;
          break;
        case SDLK_LEFT:
          myrect.rect.x -= 10.0;
          break;
        case SDLK_RIGHT:
          myrect.rect.x += 10.0;
          break;
        }
        break;
      }
    }
    // empty the back buffer
    if (!myScene.clear_scene()) {
      return mte::error_print(SDL_GetError());
    }
    // fill the back buffer
    if (!myrect.draw_myself(myScene.renderer))
      return mte::error_print(SDL_GetError());
    // display the back buffer
    if (!myScene.present()) {
      return mte::error_print(SDL_GetError());
    }
  }
  // cleanup
  return 0;
}
