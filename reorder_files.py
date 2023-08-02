import os
import shutil


def reorder_files(path, new_start_id):
    if not os.path.isdir(path):
        raise Exception('Invalid folder name: {}'.format(path))
    fns = os.listdir(path)
    ids = []
    for fn in fns:
        basename = os.path.basename(fn)
        base = os.path.splitext(basename)[0]
        fid = int(base)
        fid = fid - new_start_id + 1
        if fid <= 0:
            fid += len(fns)
        ids.append(fid)
    # id_str_width = len(str(len(fns))) + 1
    '''
    First renamed to start with "_" temporarily.
    Then rename to final name.
    '''
    for i, fn in enumerate(fns):
        fn_in = os.path.join(path, fn)
        # fn_tmp = '{}{}'.format(str(i + 1).zfill(id_str_width),
        fn_tmp = '_{}{}'.format(ids[i],
                                os.path.splitext(fn)[-1])
        fn_out = os.path.join(path, fn_tmp)
        shutil.move(fn_in, fn_out)
        print('Renamed {} to {}'.format(fn_in, fn_out))
    fns = os.listdir(path)
    for fn in fns:
        fn_out = os.path.join(path, fn[1:])
        fn_in = os.path.join(path, fn)
        shutil.move(fn_in, fn_out)
        print('Renamed {} to {}'.format(fn_in, fn_out))


def main():
    import sys
    path = sys.argv[1]
    new_start_id = int(sys.argv[2])
    reorder_files(path, new_start_id)


if __name__ == '__main__':
    main()
