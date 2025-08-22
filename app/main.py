from flask import Flask, request, jsonify, render_template
from .utils import clean_string

# single Flask app (the only one)
app = Flask(__name__)

greeting_word = "hello"

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/change-greeting")
def change_greeting():
    return render_template("change_greeting.html")

@app.route("/greet/<name>", methods=["GET"])
def greet(name):
    cleaned_name = clean_string(name)
    if not cleaned_name:
        return jsonify({"error": "Invalid name"}), 400
    return jsonify({"message": f"{greeting_word} {cleaned_name}"})

@app.route("/greeting-word", methods=["POST"])
def update_greeting():
    data = request.get_json() or {}
    word = data.get("word", "")
    cleaned_word = clean_string(word)
    if not cleaned_word:
        return jsonify({"error": "Invalid word"}), 400

    global greeting_word
    greeting_word = cleaned_word
    return jsonify({"message": "Greeting word updated successfully"})

@app.route("/health")
def health():
    # must be "healthy" to satisfy tests
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
