import os
import sys
import subprocess

import numpy as np
from PIL import Image
import imageio

def create_animated_webp(image_folder, output_file, duration_s=0.1):
    imgs = [Image.open(os.path.join(image_folder, img))
            for img in sorted(os.listdir(image_folder))
            if img.endswith(('png', 'jpg', 'jpeg'))]
    base_width, base_height = imgs[0].size
    for img in imgs:
        img = img.resize((base_width, base_height))
    frames = [np.array(img) for img in imgs]
    # Create the animation and save as WebP
    imageio.mimsave(output_file, frames, duration=duration_s / 1000, loop=0)
    print(f'Generated animated webp: {output_file}')


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
    duration_s = 0.5
    create_animated_webp(input_path, output_file, duration_s)


if __name__ == '__main__':
    main()
