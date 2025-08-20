from flask import Flask, request, jsonify, render_template
from .utils import clean_string

app = Flask(__name__)

greeting_word = "hello"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/change-greeting')
def change_greeting():
    return render_template('change_greeting.html')

@app.route('/greet/<name>', methods=['GET'])
def greet(name):
    cleaned_name = clean_string(name)
    if not cleaned_name:
        return jsonify({"error": "Invalid name"}), 400
    return jsonify({"message": "{} {}".format(greeting_word, cleaned_name)})

@app.route('/greeting-word', methods=['POST'])
def update_greeting():
    data = request.get_json()
    if not data or 'word' not in data:
        return jsonify({"error": "Missing word parameter"}), 400
    
    global greeting_word
    cleaned_word = clean_string(data['word'])
    if not cleaned_word:
        return jsonify({"error": "Invalid word"}), 400
    
    greeting_word = cleaned_word
    return jsonify({"message": "Greeting word updated successfully"})

@app.route('/health')
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 