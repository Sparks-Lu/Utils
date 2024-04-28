import sys
from bs4 import BeautifulSoup

def remove_tags(html_text):
    soup = BeautifulSoup(html_text, 'html.parser')
    text = soup.get_text()
    return text


def main():
    html_content = ''
    if len(sys.argv) > 1:
        html_filename = sys.argv[1]
        with open(html_filename, 'r') as f_tmp:
            html_content = f_tmp.read()
    else:
        # Example usage
        html_content = """
        <html>
        <head>
        <title>Example Page</title>
        </head>
        <body>
        <h1>Welcome to the Example Page</h1>
        <p>This is a paragraph with <b>bold</b> and <i>italic</i> text.</p>
        <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        </ul>
        </body>
        </html>
        """
    plain_text = remove_tags(html_content)
    print(plain_text)


if __name__ == '__main__':
    main()
