from flask import Flask, render_template, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def index():
    return render_template(
        "index.html",
        message="🚀 Deployed via GitHub Actions (OIDC) to EKS",
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/info")
def info():
    return jsonify({
        "app": "Flask EKS App"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
