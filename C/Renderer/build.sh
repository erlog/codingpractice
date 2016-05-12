#!/bin/sh
#gcc renderer.c -o renderer -I/usr/include/SDL2 -I/usr/include/x86_64-linux-gnu/ruby-2.1.0 -I/usr/include/ruby-2.1.0 -lm -lruby-2.1 -lSDL2 -lGL -Wall -Wno-unused-variable
RUBY="/System/Library/Frameworks/Ruby.framework/Versions/2.0/Headers"
SDL="/Library/Frameworks/SDL2.framework/Versions/A/Headers"
gcc renderer.c -o renderer -isystem"$RUBY" -isystem"$SDL" -lruby -lSDL2 -framework OpenGL -Wall -Wno-unused-variable

