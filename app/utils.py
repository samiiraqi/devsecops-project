from datetime import datetime
import os

def get_current_time():
    """Get current timestamp"""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def get_app_version():
    """Get application version"""
    return "1.0.0"

def get_environment():
    """Get current environment"""
    return os.getenv('ENVIRONMENT', 'development')

def format_message(message):
    """Format message with timestamp"""
    timestamp = get_current_time()
    return f"[{timestamp}] {message}"

def is_healthy():
    """Simple health check"""
    return True