import os
import glob
from PIL import Image, ImageMath


class ImageConverter(object):
    def __init__(self):
        pass

    def __del__(self):
        pass

    def distance2(self, a, b):
        return (a[0] - b[0]) * (a[0] - b[0]) + \
                (a[1] - b[1]) * (a[1] - b[1]) + \
                (a[2] - b[2]) * (a[2] - b[2])

    def distance(self, px1, px2):
        import numpy as np
        return np.sqrt(np.sum((np.array(px1) - np.array(px2)) ** 2, axis=0))

    def make_color_transparent(self, im, color):
        pixels = im.getdata()
        pixels_new = []
        for px in pixels:
            alpha = self.distance(px, color) * 255 \
                    / self.distance((0, 0, 0), (255, 255, 255))
            px_new = (px[0], px[1], px[2], int(alpha))
            # print('Input: {}, output:{}'.format(px, px_new))
            pixels_new.append(px_new)
        im = im.convert('RGBA')
        im.putdata(pixels_new)
        return im

    def make_color_transparent_2(self, im, color, thresh2=0):
        im = im.convert("RGBA")
        red, green, blue, alpha = im.split()
        im.putalpha(ImageMath.eval(
            """convert(((((t - d(c, (r, g, b))) >> 31) + 1) ^ 1) * a, 'L')""",
            t=thresh2, d=self.distance2, c=color, r=red, g=green, b=blue,
            a=alpha))
        return im


class GifCreator(object):
    def __init__(self, backend='builtin'):
        self._backend = backend

    def __del__(self):
        pass

    def write(self, path, fn_output):
        if self._backend == 'moviepy':
            self.write_moviepy(path, fn_output)
        elif self._backend == 'pillow':
            self.write_pillow(path, fn_output)
        elif self._backend == 'builtin':
            fns = glob.glob(f"{path}/*.png")
            fns = sorted(fns)
            ims = []
            for fn in fns:
                ims.append(Image.open(fn))
            duration = 50
            save_transparent_gif(ims, duration, fn_output)
        else:
            print('Unsupported backend: {}'.format(self._backend))

    def write_pillow(self, path, fn_output):
        fns = glob.glob(f"{path}/*.png")
        fns = sorted(fns)
        print('Frames to generate gif: {}'.format(fns))
        frames = []
        for fn in fns:
            frame = Image.open(fn)
            frames.append(frame)
        frame_one = frames[0]
        frame_one.save(fn_output, format="GIF", append_images=frames,
                       save_all=True, duration=50, loop=0)
        print('Wrote gif file {}'.format(fn_output))

    def write_moviepy(self, path, fn_output):
        import moviepy.editor as mpy
        fns = glob.glob(f"{path}/*.png")
        fns = sorted(fns)
        print('Frames to generate gif: {}'.format(fns))
        fps = 12
        if len(fns) > 0:
            clip = mpy.ImageSequenceClip(list(fns), fps=fps)
            clip.write_gif(fn_output, fps=fps)
            print('Created gif file: {}'.format(fn_output))


def main():
    import sys
    path = sys.argv[1]

    # first add alpha channel and convert to png
    ic = ImageConverter()
    fns = glob.glob(f"{path}/*.jpg")
    for fn in fns:
        im = Image.open(fn)
        im = ic.make_color_transparent(im, (0, 0, 0))
        bn = os.path.basename(fn)
        base = os.path.splitext(bn)[0]
        fn_output = '{}/{}.png'.format(path, base)
        im.save(fn_output)
        print('{} was added alpha channel and re-wrote as {}'.format(
            fn, fn_output))

    gc = GifCreator()
    fn_output = 'output/output.gif'
    gc.write(path, fn_output)


if __name__ == '__main__':
    main()
