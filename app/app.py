from flask import Flask, request
import subprocess

app = Flask(__name__)


@app.route("/")
def home():
    return {
        "application": "DevSecOps Demo",
        "status": "running"
    }


@app.route("/health")
def health():
    return {
        "status": "healthy"
    }


@app.route("/debug")
def debug():
    command = request.args.get("cmd", "id")
    result = subprocess.check_output(command, shell=True, text=True)
    return {
        "command": command,
        "output": result
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
