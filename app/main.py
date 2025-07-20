from flask import Flask, render_template
from app.utils import get_current_time, get_app_version, format_message, is_healthy

app = Flask(__name__)

@app.route('/')
def home():
    message = format_message("Welcome to DevSecOps Project!")
    return render_template('index.html', message=message, version=get_app_version())

@app.route('/health')
def health():
    if is_healthy():
        return 'OK'
    else:
        return 'Not OK', 500

@app.route('/time')
def current_time():
    return f"Current time: {get_current_time()}"

if __name__ == '__main__':
    # Always production-safe
    app.run(host='0.0.0.0', port=5000, debug=False)