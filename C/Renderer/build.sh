#!/bin/sh
#gcc renderer.c -o renderer -I/usr/include/x86_64-linux-gnu/ruby-2.1.0 -I/usr/include/ruby-2.1.0 -lruby-2.1 -lSDL2 -Wall -Wno-unused-variable
RUBY="/System/Library/Frameworks/Ruby.framework/Versions/2.0/Headers"
gcc renderer.c -o renderer -isystem"$RUBY" -lruby -lSDL2 -Wall -Wno-unused-variable

