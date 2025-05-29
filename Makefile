#SDL2 = $(shell sdl2-config --cflags --libs)
SDL3 = $(shell pkg-config --cflags --libs sdl3)
CXXFLAGS := -march=native -Wall -Wextra -pedantic -Werror -Werror=implicit-fallthrough -std=c++26 -fcolor-diagnostics -Wno-unused-parameter
build:
	clang++ src/main.cc -O3 $(CXXFLAGS) -o out/main $(SDL3)
build_debug:
	clang++ src/main.cc -Og -ggdb $(CXXFLAGS) -o out/main $(SDL3)
run:
	out/main
debug:
	gdb out/main
