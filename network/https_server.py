import os

import http.server
import ssl

PORT = 443
WEB_ROOT = "/path/to/your/web/root"

server_address = ('', PORT)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
ssl_context.load_cert_chain(certfile="weifantasy.com_bundle.crt",
                            keyfile="weifantasy.com.key")

os.chdir(WEB_ROOT)

print(f"Serving HTTPS on port {PORT}...")

httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)
httpd.serve_forever()
