#!/bin/sh
RUBY="/System/Library/Frameworks/Ruby.framework/Versions/2.0/Headers"
SDL="/Library/Frameworks/SDL2.framework/Versions/A/Headers"
OpenGL="/System/Library/Frameworks/OpenGL.framework/Versions/A/Headers"
gcc renderer.c -o renderer -isystem"$RUBY" -isystem"$SDL" -isystem"$OpenGL" -lruby -lSDL2 -lGLEW -framework OpenGL -Wall -Wno-unused-variable

