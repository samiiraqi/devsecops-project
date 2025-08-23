from .main import app  # re-export the Flask app so `from app import app` works

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
