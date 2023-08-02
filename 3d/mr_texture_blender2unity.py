import numpy as np
import matplotlib.pyplot as plt
import cv2 as cv


def convert_metallic_roughness_to_unity(fn_input):
    '''
    Blender
        metallic and roughness maps are packed into one texture.
        B channel: metallic
        G channel: roughness
    Unity:
        R channel: metallic
        alpha channel: smoothness

    '''
    img_in = cv.imread(fn_input, cv.IMREAD_COLOR)
    plt.title('Input blender metallic map')
    plt.imshow(cv.cvtColor(img_in, cv.COLOR_BGR2RGB))
    plt.show()

    b, g, r = cv.split(img_in)[:3]
    metallic = b
    plt.title('Metallic')
    plt.imshow(metallic, cmap=plt.cm.gray)
    plt.show()
    roughness = g
    plt.title('Roughness')
    plt.imshow(roughness, cmap=plt.cm.gray)
    plt.show()

    smoothness = 255 - roughness
    r_out = metallic
    g_out = np.zeros_like(r_out)
    b_out = np.zeros_like(r_out)
    a_out = smoothness
    img_out = cv.merge([r_out, g_out, b_out, a_out])
    plt.title('Metallic map for Unity')
    plt.imshow(cv.cvtColor(img_out, cv.COLOR_BGRA2RGBA))
    plt.show()

    import os
    dirname = os.path.dirname(fn_input)
    basename = os.path.basename(fn_input)
    base, ext = os.path.splitext(basename)
    fn_out = os.path.join(dirname, '{}_unity.png'.format(base))
    cv.imwrite(fn_out, img_out)
    print('Output texture: {}'.format(fn_out))


def main():
    import sys
    fn_input = sys.argv[1]
    convert_metallic_roughness_to_unity(fn_input)


if __name__ == '__main__':
    main()
