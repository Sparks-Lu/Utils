#!/bin/bash
magick mogrify -format JPG -quality 100% -path ./ $1
