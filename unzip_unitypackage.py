#!/usr/bin/env python3
import os
import sys
import re
import shutil
import subprocess


def extract_unitypackage(fn):
    print('untar file...')
    bn = os.path.splitext(os.path.basename(fn))[0]
    dir_untar = '/tmp/{}'.format(bn)
    if not os.path.isdir(dir_untar):
        os.mkdir(dir_untar)
    sp = subprocess.Popen(['tar', 'zxvf', fn, '-C', dir_untar])
    result = sp.wait()
    print('Finish with result={}'.format(result))
    files = os.listdir(dir_untar)
    '''
    In each uuid folder, there are files 'asset', 'pathname'
    '''
    dir_output = os.path.join(dir_untar, 'output')
    if not os.path.isdir(dir_output):
        os.mkdir(dir_output)
    for name_subfolder in files:
        # print('entry: ', name_subfolder)
        if not re.match(r'^[a-f0-9]{32}$', name_subfolder):
            print('Path name {} does not match'.format(name_subfolder))
            continue
        dir_subfolder = os.path.join(dir_untar, name_subfolder)
        if not os.path.isdir(dir_subfolder):
            print('{} not a folder'.format(dir_subfolder))
            continue
        fn_asset = os.path.join(dir_subfolder, 'asset')
        if not os.path.exists(fn_asset):
            print('File {} does not exist'.format(fn_asset))
            continue
        # print('asset file: ', fn_asset)
        fn_pathname = os.path.join(dir_subfolder, 'pathname')
        if not os.path.isfile(fn_pathname):
            print('File {} does not exist'.format(fn_asset))
            continue
        with open(fn_pathname) as fp:
            pathname = fp.read()
        if pathname.endswith('\x0a\x30\x30'):
            pathname = pathname[0:-3]
        fn_output = os.path.join(dir_output, pathname)
        # print('destination: {}'.format(fn_output))
        dir_output_tmp = os.path.dirname(fn_output)
        if not os.path.isdir(dir_output_tmp):
            # print('creating dir: ', dir_output_tmp)
            os.makedirs(dir_output_tmp, exist_ok=True)
        print('Copying from {} to {}...'.format(fn_asset, fn_output))
        shutil.copy(fn_asset, fn_output)


def main():
    if len(sys.argv) < 2:
        print('Usage {} unitypackage_filename'.format(__file__))
        return
    fn = sys.argv[1]
    if not os.path.isfile(fn):
        print('Input file {} does not exist'.format(fn))
        return
    if os.path.splitext(fn)[-1] != '.unitypackage':
        print('Input filename is not .unitypackage')
        return
    extract_unitypackage(fn)


if __name__ == '__main__':
    main()
