import os
import sys

import cv2 as cv


def generate_cover_image_from_video(video_path, output_image_path, max_wh):
    cap = cv.VideoCapture(video_path)
    if not cap.isOpened():
        print("Error: Could not open video.")
        return
    ret, frame = cap.read()
    if not ret:
        print("Error: Could not read frame from video.")
        cap.release()
        return
    height, width = frame.shape[:2]
    if width > max_wh or height > max_wh:
        scale_w = max_wh / width
        scale_h = max_wh / height
        scale = min(scale_w, scale_h)
        frame = cv.resize(frame, (int(width * scale), int(height * scale)))
    cv.imwrite(output_image_path, frame)
    cap.release()
    print(f'Cover image saved to {output_image_path}')


def generate_cover(input_path, max_wh):
    for tmp_fn in os.listdir(input_path):
        if tmp_fn.endswith('.mp4') or tmp_fn.endswith('.mov'):
            base, _ = os.path.splitext(tmp_fn)
            fn_out = '{}_cover.jpg'.format(base)
            fn_full = os.path.join(input_path, tmp_fn)
            fn_out_full = os.path.join(input_path, fn_out)
            generate_cover_image_from_video(fn_full, fn_out_full, max_wh)


def main():
    input_path = sys.argv[1]
    max_wh = 600
    generate_cover(input_path, max_wh)


if __name__ == '__main__':
    main()
