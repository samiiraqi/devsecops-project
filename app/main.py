from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")


@app.route("/")
def index():
    return render_template(
        "index.html",
        message="🚀 Deployed via GitHub Actions (OIDC) to EKS!",
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        version=APP_VERSION,
    )


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "version": APP_VERSION}), 200


@app.route("/info")
def info():
    return jsonify(
        {
            "app": "Flask EKS App",
            "version": APP_VERSION,
            "env": os.getenv("FLASK_ENV", "production"),
        }
    )


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
