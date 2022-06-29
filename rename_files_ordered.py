import os
import shutil


def rename_files_ordered(path, prefix):
    if not os.path.isdir(path):
        raise Exception('Invalid folder name: {}'.format(path))
    fns = os.listdir(path)
    fns = sorted(fns)
    # id_str_width = len(str(len(fns))) + 1
    for i, fn in enumerate(fns):
        fn_in = os.path.join(path, fn)
        # fn_tmp = '{}{}'.format(str(i + 1).zfill(id_str_width),
        fn_tmp = '{}{}{}'.format(
            prefix,
            str(i + 1),
            os.path.splitext(fn)[-1])
        fn_out = os.path.join(path, fn_tmp)
        shutil.move(fn_in, fn_out)
        print('Renamed {} to {}'.format(fn_in, fn_out))


def main():
    import sys
    path = sys.argv[1]
    if len(sys.argv) > 2:
        prefix = sys.argv[2]
    else:
        prefix = ''
    rename_files_ordered(path, prefix)


if __name__ == '__main__':
    main()
