#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_oldnames.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_video.h>
#include <algorithm>
#include <cstdint>
#include <expected>
#include <memory>
#include <print>
#include <string_view>
#include "colors.h"

constexpr int window_width = 800;
constexpr int window_height = 800;
constexpr std::string_view window_title("test");

namespace mte {

enum class SDLErrors: std::uint8_t {
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
  void operator()(SDL_Window *window) const { SDL_DestroyWindow(window); }
  void operator()(SDL_Renderer *renderer) const { SDL_DestroyRenderer(renderer); }
  void operator()(SDL_Texture *texture) const { SDL_DestroyTexture(texture); }
};

struct SDLRendererWindow {
private:
  std::unique_ptr<SDL_Renderer, sdl_deleter> renderer;
  std::unique_ptr<SDL_Window, sdl_deleter> window;
  SDLRendererWindow(const std::string_view title, int width, int height,
                     SDL_WindowFlags window_flags) {
    SDL_Renderer *renderer_tmp = nullptr;
    SDL_Window *window_tmp = nullptr;
    if (!SDL_CreateWindowAndRenderer(title.data(), width, height, window_flags,
                                     &window_tmp, &renderer_tmp)) {
        std::println("Failed to initialize SDL! {}", SDL_GetError());
        std::terminate();
    } else {
        renderer.reset(renderer_tmp);
        window.reset(window_tmp);
    }
  }
public:
  static std::expected<SDLRendererWindow,SDLErrors> create(const std::string_view title, int width, int height, SDL_WindowFlags window_flags) {
    SDL_Renderer *renderer_tmp = nullptr;
    SDL_Window *window_tmp = nullptr;
    if (!SDL_CreateWindowAndRenderer(title.data(), width, height, window_flags,
                                     &window_tmp, &renderer_tmp)) {
        return std::unexpected(SDLErrors::SDLRendererCreateError);
    } else {
        return SDLRendererWindow(title,width,height,window_flags);
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
  [[nodiscard]]
  auto set_my_color(SDL_Renderer *renderer) const -> bool{
    return SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
  }
  [[nodiscard]]
  auto draw_myself(SDL_Renderer *renderer) const -> bool{
    return set_my_color(renderer) && SDL_RenderFillRect(renderer, &rect);
  }
  rect_demo(SDL_FRect rect, SDL_Color color) : rect(rect = {.x = 0, .y = 0, .w = 0, .h = 0}), color(color = {.r = 0, .g = 0, .b = 0,.a = 0}){}
};

auto main(int argc, char **argv) -> int {
    auto state = mte::SDLRendererWindow::create(window_title, window_width, window_height, SDL_WINDOW_RESIZABLE);
    SDL_SetRenderVSync(state.renderer.get(), 1);
    SDL_ShowWindow(state.window.get());
    std::array<rect_demo, (int) (window_width * window_height / 100)> rect_vector = {};
    for(int idx = 0; idx < (window_width / 10) * (window_height / 10); ++idx) {
        rect_vector[idx] = (rect_demo({.x = (float)(10 * idx), .y = (float)(std::max(10*idx, idx)), .w = 10, .h = 10}, {.r = 0, .g = 0,.b=0,.a=0}));
    }
    for(SDL_Event e; e.type != SDL_EVENT_QUIT ;SDL_PollEvent(&e) ) {
        if(!SDL_SetRenderDrawColor(state.renderer.get(), 0, 0,0,0)) {
            std::printf("failed to clear renderer\n");
            continue;
        }
        if(!SDL_RenderClear(state.renderer.get())) {
            std::printf("failed to clear renderer\n");
            continue;
        }
        for(auto &target_rect: rect_vector) {
            if(!target_rect->draw_myself(state.renderer.get())) {
                std::printf("failed to draw rect1\n");
                continue;
            }
        }
        if(!SDL_RenderPresent(state.renderer.get())) {
            std::printf("failed to present renderer\n");
            continue;
        }
    }
    return 0;
}
