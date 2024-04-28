import os
import subprocess


def main():
    for fn in os.listdir('./'):
        if fn.endswith('.mp4'):
            base, ext = os.path.splitext(fn)
            fn_out = '{}_540p.mp4'.format(base)
            subprocess.call(['ffmpeg', '-i', fn, '-s', '960x540',
                             '-c:a', 'copy', fn_out])
            print('Saved output as file {}'.format(fn_out))


if __name__ == '__main__':
    main()
