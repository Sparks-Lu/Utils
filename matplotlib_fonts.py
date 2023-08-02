import matplotlib.font_manager


def make_html(fontname):
    return "<p>{font}: <span style='font-family:{font}; font-size: 24px;'>" \
            "{font}</p>".format(font=fontname)


def main():
    code = "\n".join([make_html(font) for font in sorted(
        set([f.name for f in matplotlib.font_manager.fontManager.ttflist]))])
    html = "<div style='column-count: 2;'>{}</div>".format(code)
    fn_out = './matplotlib_fonts.html'
    with open(fn_out, 'w') as f:
        f.write(html)
        print('Finish writing file {}'.format(fn_out))


if __name__ == '__main__':
    main()
