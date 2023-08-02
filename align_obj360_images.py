import os
from PIL import Image


class ImageAligner(object):
    def __init__(self, path, fn_config):
        self._path = path
        self._width = None
        self._height = None
        self._top_centers = []
        self._load_config(fn_config)

    def __del__(self):
        pass

    def _load_config(self, fn_config):
        '''
        Read config file
        In config file, first line is "width, height"
        For following lines, each line is for one image
        In each line, "x_center, top"
        '''
        lines = None
        with open(fn_config, 'r') as f:
            lines = f.readlines()
        print('Config {}: {}'.format(fn_config, lines))
        if lines is not None:
            for i, line in enumerate(lines):
                if i == 0:
                    width, height = line.split(',')
                    self._width = int(width)
                    self._height = int(height)
                    print('width: {}, height: {}'.format(width, height))
                else:
                    x_center, top = line.split(',')
                    x_center = int(x_center)
                    top = int(top)
                    self._top_centers.append((x_center, top))
                    print('[{}] x_center: {}, top:{}'.format(i, x_center, top))

    def _align_image(self, fn, idx):
        print('Aligning image {}...'.format(fn))
        im = Image.open(fn)
        if idx >= len(self._top_centers):
            raise Exception('No config for {}({})'.format(fn, idx))
        x_center, top = self._top_centers[idx]
        left = x_center - self._width // 2
        im_cropped = im.crop((left,
                              top,
                              left + self._width,
                              top + self._height))
        '''
        dirname = os.path.dirname(fn)
        basename = os.path.basename(fn)
        fn_out = os.path.join(dirname, 'align_{}'.format(basename))
        '''
        im_cropped.save(fn)
        im.close()
        print('Saved aligned image as {}'.format(fn))

    def align_images(self):
        if not os.path.isdir(self._path):
            raise Exception('Invalid folder name: {}'.format(self._path))
        if self._width is None or self._height is None:
            raise Exception('Config file not loaded')
        fns = os.listdir(self._path)
        fn_images = []
        for fn in fns:
            basename = os.path.basename(fn)
            base, ext = os.path.splitext(basename)
            ext = ext.lower()
            fn_full = os.path.join(self._path, fn)
            if ext == '.jpg' or ext == '.png':
                fn_images.append(fn_full)
        fn_images = sorted(fn_images,
                           key=lambda fn:
                           int(os.path.splitext(os.path.basename(fn))[0]))
        print('Files to be processed: {}'.format(fn_images))
        for i, fn in enumerate(fn_images):
            self._align_image(fn, i)


def main():
    import sys
    path = sys.argv[1]
    fn_config = sys.argv[2]
    ia = ImageAligner(path, fn_config)
    ia.align_images()


if __name__ == '__main__':
    main()
