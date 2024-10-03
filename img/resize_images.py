import os
import cv2 as cv


def resize_img(full_path, ratio=None, max_wh=None,
               target_width=None, target_height=None,
               replace=False
              ):
    img = cv.imread(full_path, cv.IMREAD_UNCHANGED)
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
    base, ext = os.path.splitext(os.path.basename(full_path))
    if not replace:
        full_path = os.path.join(os.path.dirname(full_path),
                                 # f'{base}_{dst_w}x{dst_h}{ext}')
                                 f'thumbnail_{base}{ext}')
        # full_path = os.path.join(full_path, f'{base}_thumbnail.jpg')
    cv.imwrite(full_path, new_img)
    print(f'Wrote image {full_path}')


def resize_imgs(path, ratio=None, max_wh=None,
                target_width=None, target_height=None,
                replace=False):
    if ratio is not None:
        if len(ratio) == 0:
            ratio = None
        else:
            ratio = float(ratio)
    if os.path.isfile(path):
        ext = os.path.splitext(path)[-1]
        ext = ext.lower()
        if ext in ['.jpg', '.jpeg', '.png', '.bmp', '.webp']:
            resize_img(path, ratio, max_wh, target_width, target_height,
                       replace)
        elif ext in ['.txt']:
            # list file
            img_files = []
            with open(path, 'r') as f_tmp:
                img_files = f_tmp.readlines()
            for img_file in img_files:
                img_file = img_file.strip()
                print(f'Resizing image file: {img_file}')
                resize_img(img_file, ratio, max_wh, target_width, target_height, replace)
    elif os.path.isdir(path):
        fns = os.listdir(path)
        for tmp_fn in fns:
            _, ext = os.path.splitext(tmp_fn)
            ext = ext.lower()
            fn_full = os.path.join(path, tmp_fn)
            if ext in ['.jpg', '.jpeg', '.png', '.bmp', '.webp']:
                resize_img(fn_full, ratio, max_wh, target_width, target_height,
                           replace)
    else:
        raise RuntimeError(f'Invalid path: {path}')


def main():
    path = input('Input path where image files locates: ')
    ratio = input('Input scale ratio: ')
    target_width = None
    target_height = None
    max_wh = None
    if ratio is None or len(ratio) == 0:
        max_wh = input('Input max width/height: ')
        if max_wh is None or len(max_wh) == 0:
            target_width = input('Input target width: ')
            if target_width is None or len(target_width) == 0:
                target_height = input('Input target height: ')
    replace = input('Replace original (1) or not (0): ')
    replace = int(replace) > 0
    resize_imgs(path, ratio, max_wh, target_width, target_height, replace)


if __name__ == '__main__':
    main()
