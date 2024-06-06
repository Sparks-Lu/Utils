#!/bin/bash
char_img_file="standing_shape.png"
output_file="standing_shadow.png"
font_name="WenQuanYi-Zen-Hei-Mono"
magick -background None -virtual-pixel Transparent -fill DodgerBlue \
    -pointsize 256 -font $font_name  label:A   -trim +repage \
    -gravity South -chop 0x5 $char_img_file
magick $char_img_file   -flip +distort SRT '0,0 1,-1 0' \
          \( +clone -background Black -shadow 60x5+0+0 \
             -virtual-pixel Transparent \
             +distort Affine '0,0 0,0  100,0 100,0  0,100 100,50' \
          \) +swap -background white -layers merge \
          -fuzz 2% -trim +repage $output_file
echo "Ouput image: $output_file"
