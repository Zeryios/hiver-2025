#!/bin/bash

# CONFIG
APP_NAME=hello-spring-boot:v6
DOCKER_USER=zeryios272  # <-- Changez ça
IMAGE_NAME=$DOCKER_USER/$APP_NAME

echo "🚀 Build Spring Boot application..."
./mvnw clean package -DskipTests || exit 1

echo "🐳 Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME . || exit 1

echo "🔐 Docker login"
docker login || exit 1

echo "📤 Pushing image to Docker Hub"
docker push $IMAGE_NAME || exit 1

echo "📦 Deploying to Kubernetes"
kubectl apply -f k8s-deployment.yaml || exit 1

echo "✅ Done!"
