from PIL import Image, ImageOps


class GifExtractor():
    def __init__(self):
        pass

    def __del__(self):
        pass

    def extract(self, fn, invert=False):
        im_frames = []
        with Image.open(fn) as im:
            print('{} has {} frames'.format(fn, im.n_frames))
            for i in range(im.n_frames):
                im.seek(i)
                fn_output = 'output/{}.png'.format(i)
                im.save(fn_output)
                if invert:
                    with Image.open(fn_output) as im_frame:
                        # invert() does not support alpha channel
                        im_frame = im_frame.convert('RGB')
                        im_frame = ImageOps.invert(im_frame)
                    im_frames.append(im_frame)
                    # remove png output
                    import os
                    os.remove(fn_output)
                    fn_output = 'output/{:02d}.jpg'.format(i)
                    im_frame.save(fn_output)
                else:
                    im_frames.append(im)
                print('Saved {} frame as {} (invert: {})'.format(
                    i, fn_output, invert))
        return im_frames


def test_extraction():
    import sys
    fn = sys.argv[1]
    ge = GifExtractor()
    ge.extract(fn, invert=True)
    # ge.extract(fn)


def main():
    test_extraction()


if __name__ == '__main__':
    main()
