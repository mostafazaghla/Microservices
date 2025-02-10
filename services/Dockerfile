# base image as light as possible
FROM python:3.9-slim

# environment variables
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port Flask runs on (default: 5000)
EXPOSE 5000

# Run the application
CMD ["python", "run.py"]
