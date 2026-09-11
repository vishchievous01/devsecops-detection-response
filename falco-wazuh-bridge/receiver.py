#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import json

HOST = "0.0.0.0"
PORT = 8080

WAZUH_FALCO_LOG = "/wazuh-logs/falco-events.json"


class FalcoHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        if self.path != "/falco":
            self.send_response(404)
            self.end_headers()
            return

        try:
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)

            event = json.loads(body)

            # Write one JSON event per line for Wazuh Logcollector.
            with open(WAZUH_FALCO_LOG, "a", encoding="utf-8") as f:
                json.dump(event, f, separators=(",", ":"))
                f.write("\n")
                f.flush()

            print("Received and forwarded Falco event:", flush=True)
            print(json.dumps(event, indent=2), flush=True)

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"accepted"}')

        except json.JSONDecodeError:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'{"status":"invalid_json"}')

        except Exception as e:
            print(f"Bridge error: {e}", flush=True)

            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'{"status":"error"}')

    def log_message(self, format, *args):
        return


server = HTTPServer((HOST, PORT), FalcoHandler)

print(
    f"Falco-Wazuh bridge listening on {HOST}:{PORT}",
    flush=True
)

server.serve_forever()
