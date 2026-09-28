# E-Commerce Store — Dockerized Node.js Microservices on AWS

[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ap--south--1-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

A full-stack e-commerce application implemented as a Node.js microservices system with a React frontend, MongoDB, Docker containers, Docker Hub images, and Terraform-provisioned AWS infrastructure.

This repository documents the complete implementation for the Hero Vired Skill Test 3: **Deploy a Multi-Service Node.js Application using Docker and Terraform**.

---

## 1. Project Overview

The application is composed of five application services:

| Service | Technology | Container Port | Host Port | Responsibility |
|---|---|---:|---:|---|
| Frontend | React + Nginx | 80 | 80 | Public web interface |
| User Service | Node.js + Express | 3001 | 3001 | Authentication and user management |
| Product Service | Node.js + Express | 3002 | 3002 | Products and categories |
| Cart Service | Node.js + Express | 3003 | 3003 | Shopping cart management |
| Order Service | Node.js + Express | 3004 | 3004 | Orders and checkout workflow |

MongoDB runs as an additional supporting container and stores application data in separate databases for the microservices.

---

## 2. Architecture

```text
                         Internet
                            |
                            | HTTP :80
                            v
                +------------------------+
                |     AWS EC2 Instance   |
                |       Ubuntu Linux     |
                +------------------------+
                            |
                    Docker Network
                  ecommerce-network
                            |
        +-------------------+-------------------+
        |                   |                   |
        v                   v                   v
+---------------+   +---------------+   +---------------+
| React/Nginx   |   | User Service  |   | Product       |
| Frontend      |   | :3001         |   | Service :3002 |
| :80           |   +---------------+   +---------------+
+---------------+           |                   |
        |                   |                   |
        |                   +---------+---------+
        |                             |
        v                             v
+---------------+              +---------------+
| Cart Service  |              | Order Service |
| :3003         |              | :3004         |
+---------------+              +---------------+
        |                             |
        +-------------+---------------+
                      |
                      v
               +-------------+
               | MongoDB :27017 |
               +-------------+
```

### AWS infrastructure

```text
AWS ap-south-1 (Mumbai)
|
+-- VPC
    |
    +-- Public Subnet
        |
        +-- Internet Gateway
        |
        +-- Security Group
        |   +-- TCP 80 from 0.0.0.0/0
        |   +-- TCP 22 from administrator IP
        |
        +-- EC2 Instance
            |
            +-- Docker Engine
                |
                +-- ecommerce-frontend :80
                +-- ecommerce-user-service :3001
                +-- ecommerce-product-service :3002
                +-- ecommerce-cart-service :3003
                +-- ecommerce-order-service :3004
                +-- ecommerce-mongodb :27017
```

---

## 3. Technology Stack

### Application

- Node.js
- Express.js
- React
- MongoDB / Mongoose
- Axios
- JWT authentication
- REST APIs

### Containerization

- Docker
- Docker Hub
- Docker network: `ecommerce-network`

### Infrastructure

- AWS EC2
- AWS VPC
- Public subnet
- Internet Gateway
- Security Group
- Terraform
- Ubuntu Linux

### AWS Region

```text
ap-south-1 (Mumbai)
```

---

## 4. Repository Structure

```text
E-CommerceStore/
|
+-- backend/
|   +-- user-service/
|   |   +-- Dockerfile
|   |   +-- routes/
|   |   +-- models/
|   |   +-- server.js
|   |   +-- package.json
|   |
|   +-- product-service/
|   |   +-- Dockerfile
|   |   +-- routes/
|   |   +-- models/
|   |   +-- server.js
|   |   +-- package.json
|   |
|   +-- cart-service/
|   |   +-- Dockerfile
|   |   +-- routes/
|   |   +-- models/
|   |   +-- server.js
|   |   +-- package.json
|   |
|   +-- order-service/
|       +-- Dockerfile
|       +-- routes/
|       +-- models/
|       +-- server.js
|       +-- package.json
|
+-- frontend/
|   +-- Dockerfile
|   +-- public/
|   +-- src/
|   +-- package.json
|
+-- terraform/
|   +-- main.tf
|   +-- variables.tf
|   +-- outputs.tf
|   +-- user_data.sh
|   +-- terraform.tfstate*   # local state; do not commit
|
+-- README.md
+-- LICENSE
+-- .gitignore
```

> The Terraform state file and private key files must not be committed to source control.

---

## 5. Docker Images

The five application images are published to Docker Hub under the `raviveera2305` namespace.

```text
raviveera2305/ecommerce-user-service:1.0
raviveera2305/ecommerce-product-service:1.0
raviveera2305/ecommerce-cart-service:1.0
raviveera2305/ecommerce-order-service:1.0
raviveera2305/ecommerce-frontend:1.0
```

MongoDB uses the official image:

```text
mongo:7
```

---

## 6. Docker Build and Push

Build each image from its service directory.

### User Service

```bash
docker build -t ecommerce-user-service:1.0 ./backend/user-service
docker tag ecommerce-user-service:1.0 raviveera2305/ecommerce-user-service:1.0
docker push raviveera2305/ecommerce-user-service:1.0
```

### Product Service

```bash
docker build -t ecommerce-product-service:1.0 ./backend/product-service
docker tag ecommerce-product-service:1.0 raviveera2305/ecommerce-product-service:1.0
docker push raviveera2305/ecommerce-product-service:1.0
```

### Cart Service

```bash
docker build -t ecommerce-cart-service:1.0 ./backend/cart-service
docker tag ecommerce-cart-service:1.0 raviveera2305/ecommerce-cart-service:1.0
docker push raviveera2305/ecommerce-cart-service:1.0
```

### Order Service

```bash
docker build -t ecommerce-order-service:1.0 ./backend/order-service
docker tag ecommerce-order-service:1.0 raviveera2305/ecommerce-order-service:1.0
docker push raviveera2305/ecommerce-order-service:1.0
```

### Frontend

```bash
docker build -t ecommerce-frontend:1.0 ./frontend
docker tag ecommerce-frontend:1.0 raviveera2305/ecommerce-frontend:1.0
docker push raviveera2305/ecommerce-frontend:1.0
```

---

## 7. Local Container Validation

Create the Docker network:

```bash
docker network create ecommerce-network
```

Run MongoDB:

```bash
docker run -d \
  --name ecommerce-mongodb \
  --network ecommerce-network \
  -p 27017:27017 \
  -v ecommerce-mongodb-data:/data/db \
  mongo:7
```

The backend services are connected through the Docker network and use container DNS names such as:

```text
mongodb://ecommerce-mongodb:27017/ecommerce_products
http://ecommerce-product-service:3002
http://ecommerce-cart-service:3003
http://ecommerce-user-service:3001
```

The frontend is exposed through Nginx on port 80.

---

## 8. Terraform Infrastructure

Terraform provisions the AWS infrastructure required to host the application.

The deployment includes:

- AWS provider configured for `ap-south-1`
- VPC
- Public subnet
- Internet Gateway
- Public route table and association
- EC2 instance
- Security Group
- User-data based Docker installation and deployment
- Terraform outputs for instance ID, public IP, public DNS, and frontend URL

### Terraform initialization

```powershell
terraform init
```

### Validate configuration

```powershell
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### Review the plan

```powershell
terraform plan
```

### Apply infrastructure

```powershell
terraform apply
```

Enter `yes` when Terraform asks for confirmation.

### Display outputs

```powershell
terraform output
```

Example deployment outputs from the completed deployment:

```text
frontend_url = "http://13.201.36.227"
instance_id = "i-016ea467bd20719f1"
public_dns = "ec2-13-201-36-227.ap-south-1.compute.amazonaws.com"
public_ip = "13.201.36.227"
```

The public IP is dynamic and can change if the EC2 instance is recreated. Use the current value returned by `terraform output` rather than hard-coding it in scripts.

---

## 9. EC2 User Data Deployment

The Terraform EC2 resource uses `user_data.sh` to automate application deployment after instance creation.

The script performs the following sequence:

1. Updates Ubuntu packages.
2. Installs Docker.
3. Enables and starts the Docker service.
4. Adds the `ubuntu` user to the Docker group.
5. Pulls all five application images from Docker Hub.
6. Creates the `ecommerce-network` Docker network.
7. Pulls MongoDB 7.
8. Starts MongoDB.
9. Starts User Service on port 3001.
10. Starts Product Service on port 3002.
11. Starts Cart Service on port 3003.
12. Starts Order Service on port 3004.
13. Starts the frontend on port 80.
14. Displays the running containers.

The frontend mapping is:

```text
EC2 host port 80 -> frontend container port 80
```

This matches the Nginx-based frontend image used in the deployment.

---

## 10. Security Group Configuration

The EC2 security group allows public HTTP access to the frontend:

```text
TCP 80
Source: 0.0.0.0/0
Purpose: Frontend HTTP access
```

SSH access is restricted to the administrator's public IP rather than being opened globally.

The backend services use ports 3001–3004 for service communication. The application containers communicate over the private Docker network `ecommerce-network`.

MongoDB communicates internally through the Docker network.

> For a production environment, backend and database ports should not be exposed publicly unless there is a specific requirement.

---

## 11. Deployment Verification

### Check EC2 state

```powershell
aws ec2 describe-instances `
  --profile personal `
  --region ap-south-1 `
  --instance-ids <INSTANCE_ID> `
  --query "Reservations[0].Instances[0].State.Name" `
  --output text
```

Expected:

```text
running
```

### Check Docker containers

After SSHing into the EC2 instance:

```bash
docker ps
```

The completed deployment showed the following containers running:

```text
ecommerce-frontend
 e-commerce-order-service
 ecommerce-cart-service
 ecommerce-product-service
 ecommerce-user-service
 ecommerce-mongodb
```

### Verify frontend locally on EC2

```bash
curl -I http://localhost
```

Expected:

```text
HTTP/1.1 200 OK
Server: nginx/...
Content-Type: text/html
```

### Verify frontend remotely

From Windows PowerShell:

```powershell
Invoke-WebRequest http://<PUBLIC_IP> -UseBasicParsing
```

or:

```powershell
curl.exe -i http://<PUBLIC_IP>
```

A successful deployment returns:

```text
HTTP/1.1 200 OK
Content-Type: text/html
```

### Browser verification

Open:

```text
http://<PUBLIC_IP>
```

The deployed application displays the E-Commerce homepage with navigation, login/register controls, product sections, and the application landing page.

---

## 12. Backend Health Verification

The Product Service exposes a health endpoint:

```bash
curl.exe -i http://localhost:3002/health
```

Expected response:

```json
{
  "service": "Product Service",
  "status": "OK",
  "port": "3002"
}
```

The Product Service API is mounted under `/api/products`:

```bash
curl.exe -i http://localhost:3002/api/products
```

A valid response from the completed deployment was:

```json
{
  "products": [],
  "totalPages": 0,
  "currentPage": 1,
  "total": 0
}
```

The empty product collection is valid for a fresh deployment; it confirms that the endpoint is reachable and the service can communicate with MongoDB.

---

## 13. Public Deployment

The completed Terraform deployment produced:

```text
Frontend URL:
http://13.201.36.227

Public DNS:
ec2-13-201-36-227.ap-south-1.compute.amazonaws.com

EC2 Instance:
i-016ea467bd20719f1

AWS Region:
ap-south-1
```

The public frontend returned HTTP `200 OK` during final verification.

---

## 14. Assignment Requirement Mapping

| Assignment Requirement | Implementation / Evidence |
|---|---|
| Five Dockerfiles | User, Product, Cart, Order and Frontend services |
| Build Docker images locally | Docker build commands and local image validation |
| Push images to Docker Hub | `raviveera2305/*:1.0` images |
| VPC | Terraform-managed AWS VPC |
| Public subnet | Terraform-managed public subnet |
| EC2 | Terraform-managed Ubuntu EC2 instance |
| HTTP access | Security Group TCP/80 from the internet |
| Internal service communication | Docker network `ecommerce-network` and service ports 3001–3004 |
| Install Docker automatically | `user_data.sh` |
| Pull application images automatically | `docker pull` commands in `user_data.sh` |
| Run containers automatically | `docker run` commands in `user_data.sh` |
| Public frontend | Nginx frontend exposed on EC2 port 80 |
| Backend verification | Container status and Product Service health/API checks |
| Terraform outputs | `frontend_url`, `instance_id`, `public_dns`, `public_ip` |

---

## 15. Screenshot Evidence

The project evidence currently contains screenshots **01–18**.

| Screenshot | Evidence |
|---:|---|
| 01 | GitHub repository |
| 02 | Project structure |
| 03 | Docker environment / configuration |
| 04 | User Service Dockerfile |
| 05 | Product Service Dockerfile |
| 06 | Cart Service Dockerfile |
| 07 | Order Service Dockerfile |
| 08 | Frontend Dockerfile |
| 09 | Docker images built |
| 10 | Ecommerce containers running |
| 11 | Docker network / containers |
| 12 | Terraform apply completed and outputs |
| 13 | EC2 Docker containers running |
| 14 | EC2 SSH connection |
| 15 | Docker containers running on EC2 |
| 16 | Frontend container HTTP verification |
| 17 | Public IP HTTP 200 verification |
| 18 | E-Commerce frontend in browser |

These screenshots demonstrate the progression from application/container setup through Terraform provisioning, EC2 deployment, HTTP verification, and final browser accessibility.

---

## 16. Troubleshooting Notes

### PowerShell `curl` behavior

Windows PowerShell aliases `curl` to `Invoke-WebRequest` in many environments. For predictable curl syntax, use:

```powershell
curl.exe -i http://<PUBLIC_IP>
```

### Frontend connection reset

The frontend image uses Nginx and listens on container port 80. Therefore the correct Docker mapping is:

```text
-p 80:80
```

not:

```text
-p 80:3000
```

### Product Service returns `Cannot GET /`

The Product Service does not define a root `/` endpoint. Use:

```text
/health
```

or:

```text
/api/products
```

### SSH key

The EC2 deployment uses an EC2 key pair. Keep the private `.pem` file outside the repository and never commit it to Git.

---

## 17. Cleanup

To destroy the Terraform-managed AWS infrastructure after evaluation:

```powershell
terraform destroy
```

Review the resources Terraform proposes to remove and confirm with `yes`.

After destruction, verify that the EC2 instance and associated Terraform-managed resources have been removed.

---

## 18. Security and Production Notes

This project is an educational deployment. Before using a similar architecture in production:

- Store secrets in AWS Secrets Manager or Parameter Store rather than source code or plain user-data.
- Do not use placeholder JWT secrets.
- Restrict SSH access and consider AWS Systems Manager Session Manager instead of direct SSH.
- Keep backend and MongoDB ports private.
- Use HTTPS with a domain name and TLS certificate.
- Use an Application Load Balancer for production traffic.
- Use managed MongoDB such as MongoDB Atlas or Amazon DocumentDB where appropriate.
- Use immutable image tags rather than relying only on `1.0`.
- Add centralized logging and monitoring.
- Add health checks and restart policies for containers.
- Store Terraform state remotely with locking for team environments.
- Avoid committing `.tfstate`, credentials, `.pem`, `.ppk`, and environment files containing secrets.

---

## 19. Useful Commands

### Terraform

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

### AWS

```powershell
aws ec2 describe-instances --profile personal --region ap-south-1
```

### Docker on EC2

```bash
docker ps
docker images
docker network ls
docker logs --tail 100 <container-name>
docker inspect <container-name>
```

### Frontend test

```bash
curl -I http://localhost
```

### Product Service test

```bash
curl -i http://localhost:3002/health
curl -i http://localhost:3002/api/products
```

---

## 20. Project Outcome

The completed implementation demonstrates:

- Microservices-based application architecture
- Individual Dockerfiles for five application services
- Docker image build and Docker Hub publishing
- Automated AWS infrastructure provisioning with Terraform
- Automated Docker installation and application startup through EC2 user data
- Public frontend exposure through HTTP port 80
- Internal communication between containerized services
- MongoDB-backed application services
- Terraform outputs for deployment discovery
- End-to-end verification from EC2 containers to public browser access

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
