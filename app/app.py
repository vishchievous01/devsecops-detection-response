from flask import Flask, request
import getpass
import os
import platform

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

    if command == "id":
        output = f"uid={os.getuid()} user={getpass.getuser()}"

    elif command == "whoami":
        output = getpass.getuser()

    elif command == "uname":
        output = " ".join(platform.uname())

    else:
        return {
            "error": "Command not allowed",
            "allowed_commands": ["id", "uname", "whoami"]
        }, 400

    return {
        "command": command,
        "output": output
    }


@app.route("/system")
def system():
    return {
        "python": platform.python_version(),
        "platform": platform.platform(),
        "uid": os.getuid()
    }
