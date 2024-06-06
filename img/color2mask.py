import os
import sys

import cv2
import numpy as np

def convert_to_binary_with_alpha(image_path, threshold=128):
    '''
    Assume dark pixels as mask.
    Convert white pixels as transparent.
    '''
    gray_img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    binary_img = np.zeros((gray_img.shape[0], gray_img.shape[1], 4), dtype=np.uint8)
    binary_img[:, :, :3] = 255
    binary_img[:, :, 3] = np.where(gray_img < threshold, 255, 255 - gray_img)
    return binary_img


def main():
    image_path = sys.argv[1]
    binary_img = convert_to_binary_with_alpha(image_path)
    basename_wo_ext = os.path.splitext(os.path.basename(image_path))[0]
    output_path = os.path.join(os.path.dirname(image_path),
                               f'binary_{basename_wo_ext}.png')
    cv2.imwrite(output_path, binary_img)
    print(f'Mask image is saved as {output_path}')


if __name__ == '__main__':
    main()
