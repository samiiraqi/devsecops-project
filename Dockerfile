FROM python:3.10-slim
# Create a non-root user
RUN useradd -m -u 1000 appuser
WORKDIR /app
# Copy requirements first for better caching
COPY requirements.txt .
# Create virtual environment
RUN python -m venv myenv
# Activate virtual environment
ENV PATH="/app/myenv/bin:$PATH"
# Upgrade pip and install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
# Copy application code (myenv/ is ignored by .dockerignore)
COPY . .
# Change ownership to the non-root user
RUN chown -R appuser:appuser /app
# Switch to non-root user
USER appuser
# Expose port
EXPOSE 5000
# Run the application using the virtual environment
CMD ["python", "-m" "app.main"]