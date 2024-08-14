# pip install webptools
import os
import sys
from webptools import dwebp


def main():
    new_ext = sys.argv[2]
    if new_ext not in ['.jpg', '.jpeg', '.bmp', '.png', '.gif']:
        print('Output file must be .gif/.jpg/.jpeg/.png/.bmp')
        return -2

    input_path = sys.argv[1]
    if os.path.isfile(input_path):
        base, ext1 = os.path.splitext(os.path.basename(input_path))
        ext1 = ext1.lower()
        if ext1 != '.webp':
            print('Input file must be .webp')
            return -1
        output_path = os.path.join(os.path.dirname(input_path),
                                   f'{base}{new_ext}')
        print(f'Converting {input_path} to {output_path}...')
        ret = dwebp(input_image=input_path, output_image=output_path, option="-o", logging="-v")
        print(f'Finished ret={ret}')
    elif os.path.isdir(input_path):
        fns = os.listdir(input_path)
        for fname in fns:
            full_path = os.path.join(input_path, fname)
            if os.path.isfile(full_path):
                base, ext = os.path.splitext(os.path.basename(fname))
                ext = ext.lower()
                if ext == '.webp':
                    output_path = os.path.join(input_path, f'{base}{new_ext}')
                    print(f'Converting {full_path} to {output_path}...')
                    ret = dwebp(input_image=full_path,
                                output_image=output_path,
                                option="-o", logging="-v")
                    print(f'Finished ret={ret}')


if __name__ == '__main__':
    main()
