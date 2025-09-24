from .main import app  # re-export the Flask app so `from app import app` works

# In app/__init__.py and app/main.py
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104
