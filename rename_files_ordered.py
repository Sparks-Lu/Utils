import os
import shutil


def rename_files_ordered(path):
    if not os.path.isdir(path):
        raise Exception('Invalid folder name: {}'.format(path))
    fns = os.listdir(path)
    id_str_width = len(str(len(fns))) + 1
    for i, fn in enumerate(fns):
        fn_in = os.path.join(path, fn)
        fn_tmp = '{}{}'.format(str(i + 1).zfill(id_str_width),
                               os.path.splitext(fn)[-1])
        fn_out = os.path.join(path, fn_tmp)
        shutil.move(fn_in, fn_out)
        print('Renamed {} to {}'.format(fn_in, fn_out))


def main():
    import sys
    path = sys.argv[1]
    rename_files_ordered(path)


if __name__ == '__main__':
    main()
