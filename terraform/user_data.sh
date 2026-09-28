#!/bin/bash

set -e

# Update packages
apt-get update -y

# Install Docker
apt-get install -y docker.io

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Allow the ubuntu user to use Docker
usermod -aG docker ubuntu

# Pull Docker Hub images
docker pull raviveera2305/ecommerce-user-service:1.0
docker pull raviveera2305/ecommerce-product-service:1.0
docker pull raviveera2305/ecommerce-cart-service:1.0
docker pull raviveera2305/ecommerce-order-service:1.0
docker pull raviveera2305/ecommerce-frontend:1.0

# Create Docker network
docker network create ecommerce-network || true

# Pull MongoDB image
docker pull mongo:7

# Run MongoDB
docker run -d \
  --name ecommerce-mongodb \
  --network ecommerce-network \
  -p 27017:27017 \
  -v ecommerce-mongodb-data:/data/db \
  mongo:7

# Run User Service
docker run -d \
  --name ecommerce-user-service \
  --network ecommerce-network \
  -p 3001:3001 \
  -e PORT=3001 \
  -e MONGODB_URI=mongodb://ecommerce-mongodb:27017/ecommerce_users \
  -e JWT_SECRET=your-jwt-secret-key \
  raviveera2305/ecommerce-user-service:1.0

# Run Product Service
docker run -d \
  --name ecommerce-product-service \
  --network ecommerce-network \
  -p 3002:3002 \
  -e PORT=3002 \
  -e MONGODB_URI=mongodb://ecommerce-mongodb:27017/ecommerce_products \
  raviveera2305/ecommerce-product-service:1.0

# Run Cart Service
docker run -d \
  --name ecommerce-cart-service \
  --network ecommerce-network \
  -p 3003:3003 \
  -e PORT=3003 \
  -e MONGODB_URI=mongodb://ecommerce-mongodb:27017/ecommerce_carts \
  -e PRODUCT_SERVICE_URL=http://ecommerce-product-service:3002 \
  raviveera2305/ecommerce-cart-service:1.0

# Run Order Service
docker run -d \
  --name ecommerce-order-service \
  --network ecommerce-network \
  -p 3004:3004 \
  -e PORT=3004 \
  -e MONGODB_URI=mongodb://ecommerce-mongodb:27017/ecommerce_orders \
  -e CART_SERVICE_URL=http://ecommerce-cart-service:3003 \
  -e PRODUCT_SERVICE_URL=http://ecommerce-product-service:3002 \
  -e USER_SERVICE_URL=http://ecommerce-user-service:3001 \
  raviveera2305/ecommerce-order-service:1.0

# Run Frontend
docker run -d \
  --name ecommerce-frontend \
  --network ecommerce-network \
  -p 80:80 \
  raviveera2305/ecommerce-frontend:1.0

# Display running containers
docker ps