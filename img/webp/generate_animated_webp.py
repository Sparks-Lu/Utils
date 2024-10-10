import os
import sys
import subprocess
import math

import numpy as np
from PIL import Image
import imageio


def create_animated_webp(image_folder, output_file, duration_ms=None, max_wh=None):
    imgs = [Image.open(os.path.join(image_folder, img))
            for img in sorted(os.listdir(image_folder))
            if img.endswith(('png', 'jpg', 'jpeg'))]
    base_width, base_height = imgs[0].size
    if max_wh is not None and (base_width > max_wh or base_height > max_wh):
        # resize to smaller than max_wh
        w_ratio = max_wh / base_width
        h_ratio = max_wh / base_height
        ratio = min(w_ratio, h_ratio)
        base_width = math.floor(base_width * ratio)
        base_height = math.floor(base_height * ratio)
    for img in imgs:
        img = img.resize((base_width, base_height))
    frames = [np.array(img) for img in imgs]
    # Create the animation and save as WebP
    if duration_ms is None:
        duration_ms = 3 / len(frames) * 1000
        if duration_ms > 200:
            duration_ms = 200
    imageio.mimsave(output_file, frames, duration=duration_ms, loop=0)
    print(f'Generated animated webp duration={duration_ms}: {output_file}')


def generate_webp_using_ffmpeg(input_path):
    command = [
        'ffmpeg',
        '-framerate', '10',
        '-i', f'{input_path}/frame_%03d.png',
        '-c:v', 'libwebp',
        '-lossless', '1',
        '-q:v', '50',
        'output.webp'
    ]
    subprocess.run(command, check=True)


def main():
    input_path = sys.argv[1]
    if not os.path.isdir(input_path):
        print('Usage: {__name__} {image_folder}')
    # generate_webp_using_ffmpeg(input_path)
    output_file = os.path.join(input_path, 'animated.webp')
    duration_ms = None
    if len(sys.argv) > 2:
        duration_ms = int(sys.argv[2])
    create_animated_webp(input_path, output_file, duration_ms)


if __name__ == '__main__':
    main()
