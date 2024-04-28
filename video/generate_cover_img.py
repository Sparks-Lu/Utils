import os
import sys

import cv2 as cv


def generate_cover_image_from_video(video_path, output_image_path):
    cap = cv.VideoCapture(video_path)
    if not cap.isOpened():
        print("Error: Could not open video.")
        return
    ret, frame = cap.read()
    if not ret:
        print("Error: Could not read frame from video.")
        cap.release()
        return
    cv.imwrite(output_image_path, frame)
    cap.release()
    print(f'Cover image saved to {output_image_path}')


def generate_cover(input_path):
    for tmp_fn in os.listdir(input_path):
        if tmp_fn.endswith('.mp4') or tmp_fn.endswith('.mov'):
            base, _ = os.path.splitext(tmp_fn)
            fn_out = '{}_cover.jpg'.format(base)
            fn_full = os.path.join(input_path, tmp_fn)
            fn_out_full = os.path.join(input_path, fn_out)
            generate_cover_image_from_video(fn_full, fn_out_full)


def main():
    input_path = sys.argv[1]
    generate_cover(input_path)


if __name__ == '__main__':
    main()
