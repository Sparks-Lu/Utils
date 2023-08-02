import os
import uuid
import shutil


def randomly_rename_files(path):
    if not os.path.isdir(path):
        raise Exception('Invalid folder name: {}'.format(path))
    fns = os.listdir(path)
    for fn in fns:
        fn_in = os.path.join(path, fn)
        fn_tmp = '{}{}'.format(str(uuid.uuid4()), os.path.splitext(fn)[-1])
        fn_out = os.path.join(path, fn_tmp)
        shutil.move(fn_in, fn_out)
        print('Renamed {} to {}'.format(fn_in, fn_out))


def main():
    import sys
    path = sys.argv[1]
    randomly_rename_files(path)


if __name__ == '__main__':
    main()
