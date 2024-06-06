#!/bin/bash
input_filename=$1
magick $input_filename -virtual-pixel White -distort Arc 60  arc.jpg
