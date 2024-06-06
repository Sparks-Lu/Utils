import os
import sys

import cv2
import numpy as np

def add_alpha_to_img(image_path, white_as_transparent=True):
    '''
    Add alpha channel to img
    '''
    input_img = cv2.imread(image_path, cv2.IMREAD_COLOR)
    gray_img = cv2.cvtColor(input_img, cv2.COLOR_BGR2GRAY)
    output_img = np.zeros((input_img.shape[0], input_img.shape[1], 4), dtype=np.uint8)
    output_img[:, :, :3] = input_img[:, :, :3]
    if white_as_transparent:
        output_img[:, :, 3] = 255 - gray_img
    else:
        # black as transparent
        output_img[:, :, 3] = gray_img
    return output_img


def main():
    image_path = sys.argv[1]
    binary_img = add_alpha_to_img(image_path)
    basename_wo_ext = os.path.splitext(os.path.basename(image_path))[0]
    output_path = os.path.join(os.path.dirname(image_path),
                               f'alpha_{basename_wo_ext}.png')
    cv2.imwrite(output_path, binary_img)
    print(f'Mask image is saved as {output_path}')


if __name__ == '__main__':
    main()
