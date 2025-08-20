import re

def clean_string(text):
    # Remove special characters and numbers, keep only letters and spaces
    return re.sub(r'[^a-zA-Z\s]', '', text)