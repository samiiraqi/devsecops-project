from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html', 
                         message="Hello from Flask on EKS with LoadBalancer!",
                         timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    }), 200

@app.route('/info')
def info():
    return jsonify({
        'app': 'Flask EKS App',
        'version': '1.0.0',
        'environment': os.getenv('FLASK_ENV', 'development'),
        'architecture': 'Terraform Modules + LoadBalancer Service',
        'timestamp': datetime.now().isoformat()
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)