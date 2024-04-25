# pip install webptools
import os
import sys
from webptools import dwebp


def main():
    fn_input = sys.argv[1]
    ext1 = os.path.splitext(os.path.basename(fn_input))[-1]
    ext1 = ext1.lower()
    if ext1 != '.webp':
        print('Input file must be .webp')
        return -1
    fn_output = sys.argv[2]
    ext2 = os.path.splitext(os.path.basename(fn_output))[-1]
    ext2 = ext2.lower()
    if ext2 != '.jpg' and ext2 != '.jpeg' and ext2 != 'bmp' \
       and ext2 != 'png' and ext2 != '.gif':
        print('Output file must be .gif/.jpg/.jpeg/.png/.bmp')
        return -2
    print(f'Converting {fn_input} to {fn_output}...')
    ret = dwebp(input_image=fn_input, output_image=fn_output, option="-o", logging="-v")
    print(f'Finished ret={ret}')


if __name__ == '__main__':
    main()
