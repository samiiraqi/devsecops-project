from flask import Flask, request, jsonify, render_template
from .utils import clean_string

app = Flask(__name__)

greeting_word = "hello"

# NEW: Simple user storage (in real app, use database)
users = {}

@app.route("/")
def index():
    # Renders a page that contains the phrase "Flask on EKS" (your test checks this)
    return render_template("index.html")

@app.route("/change-greeting")
def change_greeting():
    return render_template("change_greeting.html")

# NEW: Add profile page route
@app.route("/profile")
def profile_page():
    return render_template("user_profile.html")

@app.route("/greet/<name>", methods=["GET"])
def greet(name):
    cleaned_name = clean_string(name)
    if not cleaned_name:
        return jsonify({"error": "Invalid name"}), 400
    return jsonify({"message": "{} {}".format(greeting_word, cleaned_name)})

@app.route("/greeting-word", methods=["POST"])
def update_greeting():
    data = request.get_json()
    if not data or "word" not in data:
        return jsonify({"error": "Missing word parameter"}), 400
    global greeting_word
    cleaned_word = clean_string(data["word"])
    if not cleaned_word:
        return jsonify({"error": "Invalid word"}), 400
    greeting_word = cleaned_word
    return jsonify({"message": "Greeting word updated successfully"})

# NEW FEATURE: User Profile Endpoints
@app.route("/user/<username>", methods=["POST"])
def create_user(username):
    """Create a new user profile"""
    data = request.get_json()
    if not data or "email" not in data:
        return jsonify({"error": "Missing email parameter"}), 400
    
    cleaned_username = clean_string(username)
    if not cleaned_username:
        return jsonify({"error": "Invalid username"}), 400
    
    users[cleaned_username] = {
        "email": clean_string(data["email"]),
        "created": "2024"
    }
    return jsonify({"message": f"User {cleaned_username} created successfully"})

@app.route("/user/<username>", methods=["GET"])
def get_user(username):
    """Get user profile"""
    cleaned_username = clean_string(username)
    if cleaned_username in users:
        return jsonify({"user": cleaned_username, "data": users[cleaned_username]})
    return jsonify({"error": "User not found"}), 404

@app.route("/health")
def health():
    # Your test expects "healthy"
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)