# _*_ coding: utf-8 _*_

# -----------------------------------------------------------
#
# Copyright VhuanTech Corporation. All rights reserved.
#
# -----------------------------------------------------------

import os
import shutil
import glob
import cv2 as cv


def resize_img(fn_full, ratio=None, max_wh=None,
               target_width=None, target_height=None):
    img = cv.imread(fn_full)
    img_h, img_w = img.shape[:2]
    ratio_tmp = ratio
    dst_w = None
    dst_h = None
    if ratio_tmp is None:
        if target_width is not None and len(target_width) > 0:
            ratio_tmp = int(target_width) / img_w
            dst_w = target_width
            dst_h = int(img_h * dst_w / img_w)
        elif target_height is not None:
            dst_h = target_height
            dst_w = int(img_w * dst_h / img_h)
        elif max_wh is not None:
            max_wh = int(max_wh)
            ratio_tmp1 = max_wh / img_h
            ratio_tmp2 = max_wh / img_w
            if ratio_tmp1 < ratio_tmp2:
                dst_h = max_wh
                dst_w = int(img_w * dst_h / img_h)
            else:
                dst_w = max_wh
                dst_h = int(img_h * dst_w / img_w)
        else:
            raise RuntimeError('Invalid scale ratio, target width or '
                               'height')
    new_img = cv.resize(img, (dst_w, dst_h))
    base, ext = os.path.splitext(fn_full)
    new_fn = os.path.join(fn_full, f'{base}_{dst_w}x{dst_h}{ext}')
    cv.imwrite(new_fn, new_img)
    print(f'Wrote image {new_fn}')


def collect_imgs(src_dir):
    if not os.path.isdir(src_dir):
        raise RuntimeError(f'Invalid folder: {src_dir}')

    dst_dir = os.path.join(src_dir, 'images')
    if os.path.isdir(dst_dir):
        raise RuntimeError(f'Folder not empty: {dst_dir}')
    os.makedirs(dst_dir)

    subdirs = os.listdir(src_dir)

    copied_images = 0

    for subdir in subdirs:
        if not os.path.isdir(os.path.join(src_dir, subdir)):
            continue

        subdir_path = os.path.join(src_dir, subdir)
        fn_imgs = []
        if os.name == 'nt':
            # ignore case
            fn_imgs = glob.glob(subdir_path + "/*.jpg") + \
                glob.glob(subdir_path + "/*.png")
        elif os.name == 'posix':
            fn_imgs = glob.glob(subdir_path + "/*.jpg") + \
                glob.glob(subdir_path + "/*.png") + \
                glob.glob(subdir_path + "/*.JPG") + \
                glob.glob(subdir_path + "/*.PNG")
        else:
            raise Exception(f'Unsupported os: {os.name}')
        for fn_img in fn_imgs:
            src_path = os.path.join(subdir_path, fn_img)
            _, ext = os.path.splitext(fn_img)
            new_fn = f'{copied_images + 1:03d}{ext}'
            dst_path = os.path.join(dst_dir, new_fn)
            shutil.copy(src_path, dst_path)
            copied_images += 1
            print(f'Copied {src_path} to {dst_path}')


def main():
    path = input('Input path where image files locates: ')
    collect_imgs(path)


if __name__ == '__main__':
    main()
