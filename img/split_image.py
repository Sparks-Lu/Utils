# _*_ coding: utf-8 _*_

# -----------------------------------------------------------
#
# Copyright VhuanTech Corporation. All rights reserved.
#
# -----------------------------------------------------------

import os
import sys
import uuid

import cv2 as cv


def split_img_h(input_img, division_num):
    img_h, img_w = input_img.shape[:2]
    div_w = img_w // division_num
    output_imgs = []
    for i in range(division_num):
        tmp_img = input_img[:, i * div_w: (i + 1) * div_w]
        output_imgs.append(tmp_img)
    return output_imgs


def main():
    input_path = sys.argv[1]
    division_num = int(sys.argv[2])
    input_img = cv.imread(input_path)
    output_imgs = split_img_h(input_img, division_num)
    dirname = os.path.dirname(input_path)
    base = os.path.splitext(os.path.basename(input_path))[0]
    img_uuid = uuid.uuid4()
    for i, img in enumerate(output_imgs):
        output_path = os.path.join(dirname, f'{base}_{i}.jpg')
        cv.imwrite(output_path, img)
        print(f'Wrote image {output_path}')


if __name__ == '__main__':
    main()
