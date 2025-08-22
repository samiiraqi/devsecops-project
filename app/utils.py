import re

def clean_string(text: str) -> str:
    """Remove non-letters; keep letters and spaces only."""
    return re.sub(r"[^a-zA-Z\s]", "", text or "")
