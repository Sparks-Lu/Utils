import os
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


def resize_imgs(path, ratio=None, max_wh=None,
                target_width=None, target_height=None):
    if ratio is not None:
        if len(ratio) == 0:
            ratio = None
        else:
            ratio = float(ratio)
    if os.path.isfile(path):
        resize_img(path, ratio, target_width, target_height)
    elif os.path.isdir(path):
        fns = os.listdir(path)
        for tmp_fn in fns:
            _, ext = os.path.splitext(tmp_fn)
            ext = ext.lower()
            fn_full = os.path.join(path, tmp_fn)
            if ext in ['.jpg', '.jpeg', '.png']:
                resize_img(fn_full, ratio, max_wh, target_width, target_height)
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
    resize_imgs(path, ratio, max_wh, target_width, target_height)


if __name__ == '__main__':
    main()
