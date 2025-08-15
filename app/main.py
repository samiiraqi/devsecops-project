# app/main.py
from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "1.0.1")  # bumped version

@app.route('/')
def index():
    return render_template(
        'index.html',
        message="🚀 Deployed via GitHub Actions! (auto)",
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        version=APP_VERSION
    )

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': APP_VERSION
    }), 200

@app.route('/info')
def info():
    return jsonify({
        'app': 'Flask EKS App',
        'version': APP_VERSION,
        'environment': os.getenv('FLASK_ENV', 'production'),
        'architecture': 'Terraform + EKS + NLB',
        'timestamp': datetime.now().isoformat()
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
