#!/bin/sh
cd output
mogrify -format png *.bmp
rm *.bmp
cd -
