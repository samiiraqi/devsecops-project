# tests/test_main.py
import os
import pytest
from app import app as flask_app  # works because of app/__init__.py

@pytest.fixture
def client():
    os.environ["APP_VERSION"] = "9.9.9"
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as c:
        yield c

def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    data = r.get_json()
    assert data["status"] == "healthy"


def test_root_page(client):
    r = client.get("/")
    assert r.status_code == 200
    assert b"Flask on EKS" in r.data
