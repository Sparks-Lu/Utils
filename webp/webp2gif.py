import webp


def main():
    import sys
    fn = sys.argv[1]
    # Load a PIL image array from the specified .webp animation file
    anim = webp.load_images(fn)

    # Grab a reference to the first frame, and save the entire PIL image
    # array as GIF with 70ms frames (14.286 FPS)
    anim[0].save('output.gif',
                 save_all=True,
                 append_images=anim[0:],
                 duration=70,
                 loop=0)
    print('Converted {} to output.gif'.format(fn))


if __name__ == '__main__':
    main()
