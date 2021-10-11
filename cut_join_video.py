import os
import subprocess
import time


def cut_join_video(fn, fn_span):
    if not fn.endswith('.mp4'):
        print('{} not valid mp4 file'.format(fn))
        return
    base, ext = os.path.splitext(os.path.basename(fn))
    # get span info
    spans = []
    '''
    spans = [
        (19, 58),
        (65, 78),
        (100, 144),
    ]
    '''
    with open(fn_span, 'r') as f:
        lines = f.readlines()
        for line in lines:
            start, end = line.split(',')
            spans.append((float(start.strip()), float(end.strip())))
    print('spans: {}'.format(spans))
    # crop videos
    fns_seg = []
    for i, span in enumerate(spans):
        start, end = span
        duration = float(end) - float(start)
        fn_out_tmp = '/tmp/{}_output_{}.mp4'.format(base, i)
        fns_seg.append(fn_out_tmp)
        cmd = ['ffmpeg',
               '-ss', str(start),
               '-i', fn,
               '-c', 'copy',
               '-t', str(duration),
               fn_out_tmp,
               ]
        print('Executing {}...'.format(cmd))
        subprocess.call(cmd)
        print('Saved cropped output as file {}'.format(fn_out_tmp))
    # generate file list
    fn_list = '/tmp/list_{}.txt'.format(time.time())
    with open(fn_list, 'w') as f:
        for fn in fns_seg:
            f.write('file \'{}\'\n'.format(fn))
        print('Saved list file {}'.format(fn_list))
    # merge videos
    fn_out = '/tmp/{}_output.mp4'.format(base)
    cmd = ['ffmpeg',
           '-f', 'concat',
           '-safe', '0',
           '-i', fn_list,
           # force to 30fps
           '-r', '30',
           fn_out,
           ]
    print('Executing {}...'.format(cmd))
    subprocess.call(cmd)
    print('Saved merged video file {}'.format(fn_out))


def main():
    import sys
    if len(sys.argv) < 2:
        print('Usage: python {} mp4_file'.format(__file__))
        return -1
    fn_video = sys.argv[1]
    if len(sys.argv) > 2:
        fn_span = sys.argv[2]
    else:
        basename = os.path.basename(fn_video)
        base = os.path.splitext(basename)[0]
        fn_span = '{}/{}.csv'.format(os.path.dirname(fn_video), base)
    if fn_video.endswith('.mp4'):
        cut_join_video(fn_video, fn_span)
    else:
        print('Usage: python {} mp4_file'.format(__file__))


if __name__ == '__main__':
    main()
