#!/bin/bash
RUBY_LIB="/usr/local/Cellar/ruby/2.2.4/include/ruby-2.2.0"
RUBY_PLATFORM_LIB="/usr/local/Cellar/ruby/2.2.4/include/ruby-2.2.0/x86_64-darwin15"
gcc renderer.c -v -o renderer -I"$RUBY_LIB" -I"$RUBY_PLATFORM_LIB" -lruby -lSDL2 -Wall -Wno-unused-variable
