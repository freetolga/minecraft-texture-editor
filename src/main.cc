#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_oldnames.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_video.h>
#include <cstddef>
#include <expected>
#include <memory>
#include <print>
#include <string_view>
#include <utility>

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
  void operator()(SDL_Window *p) const { SDL_DestroyWindow(p); }
  void operator()(SDL_Renderer *p) const { SDL_DestroyRenderer(p); }
  void operator()(SDL_Texture *p) const { SDL_DestroyTexture(p); }
};

auto error_print(std::string_view error) -> int {
  std::println("Error {}", error);
  return -1;
}

struct SDLRendererWindow {
private:
  std::expected<std::unique_ptr<SDL_Renderer, sdl_deleter>,SDLErrors> renderer;
  std::expected<std::unique_ptr<SDL_Window, sdl_deleter>,SDLErrors> window;


public:
  SDLRendererWindow(const char *title, int width, int height,
                     SDL_WindowFlags window_flags) {
    SDL_Renderer *renderer_tmp;
    SDL_Window *window_tmp;
    if (!SDL_CreateWindowAndRenderer(title, width, height, window_flags,
                                     &window_tmp, &renderer_tmp)) {
      renderer =  std::unexpected(SDLErrors::SDLRendererCreateError);
      window =  std::unexpected(SDLErrors::SDLWindowCreateError);
    } else {
        renderer->reset(renderer_tmp);
    }
  }
};

struct SDLInitializer {
  uint32_t subsystems;

public:
    SDLInitializer(uint32_t subsystems_dummy) { if(SDL_Init(subsystems_dummy)) this->subsystems = subsystems_dummy; else std::abort(); }
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
  /*
  if (argc < 2) {
    std::println("Usage: {} <Load Path> <Save Path>", argv[0]);
    return -1;
  }
  */

  auto rendererwindow =
      mte::SDLRendererWindowCreate("abc", 10, 10, SDL_WINDOW_RESIZABLE);

  defer { myScene.deinit_sdl(); };

  if (!myScene.init_scene("Minecraft Texture Editor", 256, 256,
                          SDL_WINDOW_RESIZABLE)) {
    return mte::error_print(SDL_GetError());
  }

  defer { myScene.destroy_scene(); };

  myScene.change_scene_color(0, 0, 0, 0);
  myScene.apply_color();

  rect_demo myrect(
      SDL_FRect{
          .x = 10.0,
          .y = 10.0,
          .w = 10.0,
          .h = 10.0,
      },

      SDL_Color{
          .r = 0,
          .g = 0,
          .b = 255,
          .a = 0,
      });
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
  return 0;
}
