import os


def get_files_in_path(path, suffix, recursive):
    fns = []
    print('Scanning {} for suffix={}...'.format(path, suffix))
    for fn in os.listdir(path):
        fn_full = os.path.join(path, fn)
        if os.path.isfile(fn_full):
            print('Found file {}'.format(fn_full))
            if fn.lower().endswith(suffix):
                fns.append(fn_full)
        elif recursive and os.path.isdir(fn_full):
            print('Found path {}'.format(fn_full))
            fns_sub = get_files_in_path(fn_full, suffix, recursive)
            fns.extend(fns_sub)
    return fns


def concat_src_files(path, suffix, recursive, fn_out):
    try:
        fns = get_files_in_path(path, suffix, recursive)
        print('Concating {}...'.format(fns))
        with open(fn_out, 'w') as f_out:
            for fn in fns:
                with open(fn, 'r') as f:
                    buf = f.read()
                    f.close()
                f_out.write(buf)
            f_out.close()
    except Exception as e:
        print('Exception happened: {}'.format(e))


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-r', '--recursive',
                    action='store_true',
                    help='Whether or not search files recursively')
    ap.add_argument('path', help='path or filename to be processed')
    ap.add_argument('suffix', help='target suffix')

    args = ap.parse_args()

    path = args.path
    suffix = args.suffix
    if args.recursive:
        recursive = True
    else:
        recursive = False
    fn_out = 'out.txt'
    concat_src_files(path, suffix, recursive, fn_out)
    print('Concat finished. Output file: {}'.format(fn_out))


if __name__ == '__main__':
    main()
