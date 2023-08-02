import os
import sys
import subprocess


def main():
    path = sys.argv[1]
    for fn in os.listdir(path):
        if fn.endswith('.jpg'):
            base, ext = os.path.splitext(fn)
            fn_full = os.path.join(path, fn)
            fn_out = '{}_2K.jpg'.format(base)
            subprocess.call(['convert', fn_full, '-resize', '2048x1024', fn_out])
            print('Saved output as file {}'.format(fn_out))


if __name__ == '__main__':
    main()
