#SDL2 = $(shell sdl2-config --cflags --libs)
SDL3 = $(shell pkg-config --cflags --libs sdl3)
CXXFLAGS := -Wall -Wextra -Wpedantic -Werror -Werror=implicit-fallthrough -std=c++26 -Wno-unused-parameter
build:
	g++-15 src/main.cc -O2 -pipe -march=native $(CXXFLAGS) -o out/main $(SDL3)
build_debug:
	g++-15 src/main.cc -Og -pipe -march=native -ggdb $(CXXFLAGS) -o out/main $(SDL3)
run:
	out/main
debug:
	gdb out/main
cppcheck:
	cppcheck src/main.cc --inconclusive --library=posix --enable=all
