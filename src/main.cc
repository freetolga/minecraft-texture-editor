#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_init.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_video.h>
#include <print>

class Scene {
  public:
  
  SDL_Color background_color;
  SDL_Window * window;
  SDL_Renderer * renderer;
  bool init_sdl() {
    return SDL_InitSubSystem(SDL_INIT_VIDEO);
  }
  bool init_scene(const char * title, int width, int height, SDL_WindowFlags window_flags) {
    return SDL_CreateWindowAndRenderer(title, width, height, window_flags, &window, &renderer);
  } 
  void change_scene_color(int r, int g, int b, int a) {
    background_color.r = r;
    background_color.g = g;
    background_color.b = b;
    background_color.a = a;
  }
  bool apply_color(void) {
    return SDL_SetRenderDrawColor(renderer, background_color.r, background_color.g, background_color.b, background_color.a);
  }
  bool clear_scene(void) {
    return SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0) && SDL_RenderClear(renderer);
  }
  bool present(void) {
    return SDL_RenderPresent(renderer);
  }
  ~Scene() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
  }
};

class rect_demo {
  public:
  SDL_FRect rect;
  SDL_Color color;
  bool set_my_color(SDL_Renderer* renderer) {
    return SDL_SetRenderDrawColor(renderer,color.r,color.g,color.b,color.a);
  }
  bool draw_myself(SDL_Renderer * renderer) {
    return set_my_color(renderer) && SDL_RenderFillRect(renderer, &rect);
  }
};

int main(void) {
  Scene myScene;
  if(!myScene.init_sdl()) {
    std::printf("%s\n",SDL_GetError());
    return -1;
  }
  myScene.init_scene("Minecraft Texture Editor",256,256,SDL_WINDOW_RESIZABLE);
  myScene.change_scene_color(0,0,0,0);
  myScene.apply_color();


  rect_demo myrect;
  myrect.rect.w = 10;
  myrect.rect.h = 10;
  myrect.rect.x = 10;
  myrect.rect.y = 10;

  myrect.color.r = 0;
  myrect.color.g = 0;
  myrect.color.b = 255;
  myrect.color.a = 0;
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
          myrect.rect.y -= 1.0;
          break;
        case SDLK_DOWN:
          myrect.rect.y += 1.0;
          break;
        case SDLK_LEFT:
          myrect.rect.x -= 1.0;
          break;
        case SDLK_RIGHT:
          myrect.rect.x += 1.0;
          break;
        }
        break;
      }
    }
    // empty the back buffer
    if(!myScene.clear_scene()) {
      std::printf("%s\n",SDL_GetError());
      return -1;
    }
    // fill the back buffer
    if(!myrect.draw_myself(myScene.renderer)) std::printf("%s\n",SDL_GetError());
    SDL_Delay(4);
    // display the back buffer
    if(!myScene.present()) {
      std::printf("%s\n",SDL_GetError());
      return -1;
    }
  }
  // cleanup
  return 0;
}
