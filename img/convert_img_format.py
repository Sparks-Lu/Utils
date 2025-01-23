import os
import cv2 as cv


def convert_img(fn_full, output_ext):
    bname = os.path.basename(fn_full)
    base, ext = os.path.splitext(bname)
    fn_new = os.path.join(os.path.dirname(fn_full), f'{base}{output_ext}')
    img = cv.imread(fn_full)
    print(f'image shape: {img.shape}')
    cv.imwrite(fn_new, img)
    print(f'Wrote image {fn_new}')


def convert_imgs(path, input_ext, output_ext):
    if input_ext is None or output_ext is None:
        raise RuntimeError(f'Invad input ext {input_ext} or '
                           f'output ext {output_ext}')
    if os.path.isfile(path):
        _, ext = os.path.splitext(os.path.basename(path))
        ext = ext.lower()
        if ext == input_ext:
            convert_img(path, output_ext)
    elif os.path.isdir(path):
        fns = os.listdir(path)
        for tmp_fn in fns:
            _, ext = os.path.splitext(tmp_fn)
            ext = ext.lower()
            fn_full = os.path.join(path, tmp_fn)
            if ext == input_ext:
                convert_img(fn_full, output_ext)
    else:
        raise RuntimeError(f'Invalid path: {path}')


def main():
    path = input('Input path where image files locates: ')
    input_ext = input('Input source file extension to be converted from: ')
    output_ext = input('Input target file extension to be converted to: ')
    convert_imgs(path, input_ext, output_ext)


if __name__ == '__main__':
    main()
