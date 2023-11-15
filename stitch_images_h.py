import os
import sys

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt


def stitch_imgs_h(dir_name):
    fns = os.listdir(dir_name)
    print(f'Files to be stitched horizontally: {fns}')
    fns_full = [os.path.join(dir_name, fn) for fn in fns]
    fns_full = sorted(fns_full)
    imgs = [cv.imread(fn) for fn in fns_full]
    output_img = np.hstack(imgs)
    return output_img


def main():
    dir_name = sys.argv[1]
    output_img = stitch_imgs_h(dir_name)
    fn_output = os.path.join(dir_name, 'stitched.jpg')
    cv.imwrite(fn_output, output_img)
    print(f'Output file: {fn_output}')


if __name__ == '__main__':
    main()
