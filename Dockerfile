# --- Stage 1: Build React ---
FROM node:14 AS frontend_build
WORKDIR /frontend

# Copy package.json and install dependencies
COPY frontend/package*.json ./
RUN npm install

# Copy the frontend code
COPY frontend/ ./
RUN npm run build

# --- Stage 2: Python / Flask ---
FROM python:3.9-slim
WORKDIR /app

# Install dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ .

# Copy React frontend build
COPY --from=frontend_build /frontend/build ./build

# Install Gunicorn
RUN pip install gunicorn

# Create volume-mapped directories for persistence
VOLUME ["/data"]
VOLUME ["/uploads"]

# Ensure the directories exist
RUN mkdir -p /data /uploads

# Expose Flask port
EXPOSE 5000

# Use Gunicorn to run the app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
