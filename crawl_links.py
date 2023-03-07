#!/usr/bin/python
# Adapted from example in Ch.3 of "Web Scraping With Python,
# Second Edition" by Ryan Mitchell

import re
import requests
from bs4 import BeautifulSoup

pages = set()


def get_links(root_url, page_url):
    global pages
    pattern = re.compile("^(/)")
    # fstrings require Python 3.6+
    url_page = '{}/{}'.format(root_url, page_url)
    print('Get {}...'.format(url_page))
    html = requests.get(url_page).text
    print('Finished.')
    soup = BeautifulSoup(html, "html.parser")
    for link in soup.find_all("a", href=pattern):
        if "href" in link.attrs:
            if link.attrs["href"] not in pages:
                new_page = link.attrs["href"]
                print('Found link: {}'.format(new_page))
                pages.add(new_page)
                get_links(root_url, new_page)


def main():
    import sys
    if len(sys.argv) < 2:
        print('Usage: {} root_url'.format(__file__))
        return
    root_url = sys.argv[1]
    get_links(root_url, "")


if __name__ == '__main__':
    main()
