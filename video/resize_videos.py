import os
import shutil
import subprocess


def resize_video(fn_video, target_res, replace):
    if fn_video.endswith('.mp4'):
        base = os.path.splitext(fn_video)[0]
        fn_out = f'{base}_{target_res}.mp4'
        fn_out_full = os.path.join(os.path.dirname(fn_video), fn_out)
        print(f'Processing file {fn_video}...')
        subprocess.call(['ffmpeg', '-i', fn_video,
                         '-loglevel', 'error',
                         '-s', target_res,
                         '-c:a', 'copy',
                         fn_out_full])
        if replace:
            shutil.move(fn_out_full, fn_video)
            fn_out_full = fn_video
            print('Saved output as file {}'.format(fn_out_full))


def resize_videos(input_folder, target_res, replace):
    for tmp_fn in os.listdir(input_folder):
        fn_full = os.path.join(input_folder, tmp_fn)
        if os.path.isfile(fn_full):
            resize_video(fn_full, target_res, replace)
        elif os.path.isdir(fn_full):
            resize_videos(fn_full, target_res, replace)


def main():
    input_folder = input('Input the full path for vidoes to be processed: ')
    target_res = input('Input the target video resolution, like 960x540: ')
    replace = input('Replace original file, 1 for yes, 0 for no: ')
    replace = bool(int(replace.strip()))
    resize_videos(input_folder, target_res, replace)


if __name__ == '__main__':
    main()
