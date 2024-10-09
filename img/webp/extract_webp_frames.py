import os
import sys

import webp


def extract_webp_frames(webp_file, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    frames = webp.load_images(webp_file)
    frame_count = len(frames)
    print(f'Total {frame_count} frames in {webp_file}')
    for i, frame in enumerate(frames):
        frame_output_file = os.path.join(output_dir, f'frame_{i:03d}.png')
        frame.save(frame_output_file)
        print(f'Saved [{i}] frame as {frame_output_file}')


def main():
    webp_file = sys.argv[1]
    output_dir = os.path.join(os.path.dirname(webp_file), 'frames')
    extract_webp_frames(webp_file, output_dir)


if __name__ == '__main__':
    main()
