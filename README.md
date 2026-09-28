# E-Commerce Store

Dockerized Node.js microservices deployed on AWS EC2 with Terraform.

This repository contains a multi-service e-commerce application built with React, Node.js/Express, MongoDB, Docker, Docker Hub and Terraform. The project was completed as part of the Hero Vired Skill Test 3 requirement to deploy a multi-service Node.js application using Docker and Terraform.

## Overview

The application is split into a React frontend and four backend services. Each application component runs in its own Docker container, with MongoDB running as a separate container on the same Docker network.

| Component | Port | Purpose |
|---|---:|---|
| Frontend / Nginx | 80 | Public web application |
| User Service | 3001 | User and authentication operations |
| Product Service | 3002 | Products and categories |
| Cart Service | 3003 | Shopping cart operations |
| Order Service | 3004 | Order and checkout operations |
| MongoDB | 27017 | Application data store |

The services communicate through the Docker network `ecommerce-network`. Only the frontend is exposed publicly through HTTP.

## Architecture

```text
                              Internet
                                  |
                              TCP :80
                                  |
                                  v
                    +----------------------------+
                    |       AWS EC2 / Ubuntu     |
                    |                            |
                    |        Docker Engine       |
                    |                            |
                    |  +----------------------+  |
                    |  | Frontend / Nginx :80 |  |
                    |  +----------+-----------+  |
                    |             |              |
                    |       ecommerce-network    |
                    |             |              |
                    |  +----------+-----------+  |
                    |  |          |           |  |
                    |  v          v           v  |
                    | User      Product      Cart|
                    | :3001     :3002       :3003|
                    |                         |  |
                    |              +----------+  |
                    |              | Order :3004 |
                    |              +------+-------+
                    |                     |
                    |              +------+-------+
                    |              | MongoDB :27017|
                    |              +--------------+
                    +----------------------------+
                                  |
                         Public subnet / IGW
                                  |
                              AWS VPC
```

### AWS layout

```text
AWS ap-south-1
└── VPC
    └── Public Subnet
        ├── Internet Gateway
        ├── Route Table
        ├── Security Group
        │   ├── TCP 80 from 0.0.0.0/0
        │   └── TCP 22 from administrator CIDR
        └── EC2 / Ubuntu
            └── Docker containers
```

## Technology Stack

### Application

- React
- Node.js 20
- Express.js
- MongoDB / Mongoose
- REST APIs
- JWT authentication

### Containerization

- Docker
- Docker Hub
- Docker network
- Nginx for the frontend container

### Infrastructure

- AWS EC2
- AWS VPC
- Public subnet
- Internet Gateway
- Security Groups
- Terraform
- Ubuntu Linux

**AWS Region:** `ap-south-1` (Mumbai)

## Repository Structure

```text
E-CommerceStore/
├── backend/
│   ├── user-service/
│   │   ├── Dockerfile
│   │   ├── models/
│   │   ├── routes/
│   │   ├── middleware/
│   │   ├── server.js
│   │   └── package.json
│   ├── product-service/
│   │   ├── Dockerfile
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   └── package.json
│   ├── cart-service/
│   │   ├── Dockerfile
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   └── package.json
│   └── order-service/
│       ├── Dockerfile
│       ├── models/
│       ├── routes/
│       ├── server.js
│       └── package.json
├── frontend/
│   ├── Dockerfile
│   ├── public/
│   ├── src/
│   └── package.json
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   └── .terraform.lock.hcl
├── screenshots/
├── .gitignore
├── LICENSE
└── README.md
```

Terraform state, environment-specific variable files, credentials and private keys are intentionally excluded from source control.

## Docker Images

The five application images are published under the Docker Hub account `raviveera2305`.

```text
raviveera2305/ecommerce-user-service:1.0
raviveera2305/ecommerce-product-service:1.0
raviveera2305/ecommerce-cart-service:1.0
raviveera2305/ecommerce-order-service:1.0
raviveera2305/ecommerce-frontend:1.0
```

MongoDB uses the official `mongo:7` image.

## Building the Images

Build the five application images from the repository root:

```bash
docker build -t ecommerce-user-service:1.0 ./backend/user-service
docker build -t ecommerce-product-service:1.0 ./backend/product-service
docker build -t ecommerce-cart-service:1.0 ./backend/cart-service
docker build -t ecommerce-order-service:1.0 ./backend/order-service
docker build -t ecommerce-frontend:1.0 ./frontend
```

Tag and push the images:

```bash
docker tag ecommerce-user-service:1.0 raviveera2305/ecommerce-user-service:1.0
docker tag ecommerce-product-service:1.0 raviveera2305/ecommerce-product-service:1.0
docker tag ecommerce-cart-service:1.0 raviveera2305/ecommerce-cart-service:1.0
docker tag ecommerce-order-service:1.0 raviveera2305/ecommerce-order-service:1.0
docker tag ecommerce-frontend:1.0 raviveera2305/ecommerce-frontend:1.0

docker push raviveera2305/ecommerce-user-service:1.0
docker push raviveera2305/ecommerce-product-service:1.0
docker push raviveera2305/ecommerce-cart-service:1.0
docker push raviveera2305/ecommerce-order-service:1.0
docker push raviveera2305/ecommerce-frontend:1.0
```

## Terraform Deployment

Terraform provisions the AWS infrastructure. Application image creation and Docker Hub publishing are handled separately.

### Prerequisites

- AWS CLI
- Terraform 1.6 or later
- Docker
- AWS credentials with permission to create the required EC2 and VPC resources

Configure the AWS CLI profile used by the deployment:

```powershell
aws configure --profile personal
```

### Terraform files

| File | Purpose |
|---|---|
| `main.tf` | AWS provider, VPC, subnet, networking, security group and EC2 resources |
| `variables.tf` | Deployment variables |
| `outputs.tf` | Public IP, DNS, instance ID and frontend URL |
| `user_data.sh` | EC2 bootstrap and Docker deployment |
| `.terraform.lock.hcl` | Terraform provider dependency lock file |

### Initialize

```powershell
cd terraform
terraform init
```

### Validate

```powershell
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### Review and apply

```powershell
terraform plan
terraform apply
```

Review the plan and enter `yes` when prompted.

### View deployment outputs

```powershell
terraform output
```

The deployment exposes:

```text
frontend_url
instance_id
public_dns
public_ip
```

The EC2 public IP is assigned by AWS and may change if the instance is recreated. Use the current Terraform output rather than hard-coding an address.

## EC2 Bootstrap

The EC2 instance executes `user_data.sh` during first boot. The script:

1. Updates the Ubuntu package index.
2. Installs Docker.
3. Enables and starts Docker.
4. Adds the `ubuntu` user to the Docker group.
5. Pulls the five application images from Docker Hub.
6. Creates `ecommerce-network`.
7. Starts MongoDB.
8. Starts User Service on port 3001.
9. Starts Product Service on port 3002.
10. Starts Cart Service on port 3003.
11. Starts Order Service on port 3004.
12. Starts the frontend through Nginx on port 80.
13. Displays the running containers.

The application services use Docker DNS names for internal communication. Examples include:

```text
mongodb://ecommerce-mongodb:27017/ecommerce_products
http://ecommerce-product-service:3002
http://ecommerce-cart-service:3003
http://ecommerce-user-service:3001
```

## Security Group

The EC2 security group used by the deployment provides the required external access:

| Rule | Source | Purpose |
|---|---|---|
| TCP 80 | `0.0.0.0/0` | Public frontend access |
| TCP 22 | Administrator CIDR | SSH administration |

The backend services and MongoDB communicate over the Docker network and do not need public inbound access.

For production use, SSH access should be restricted to an approved administrative network and application secrets should be supplied through a dedicated secrets-management solution.

## Deployment Verification

### 1. Confirm the EC2 instance

```powershell
aws ec2 describe-instances `
  --profile personal `
  --region ap-south-1 `
  --instance-ids <INSTANCE_ID> `
  --query "Reservations[0].Instances[0].State.Name" `
  --output text
```

Expected state:

```text
running
```

### 2. Confirm the containers

SSH to the EC2 instance and run:

```bash
docker ps
```

The completed deployment should show:

```text
ecommerce-frontend
ecommerce-user-service
ecommerce-product-service
ecommerce-cart-service
ecommerce-order-service
ecommerce-mongodb
```

### 3. Verify the frontend locally on EC2

```bash
curl -I http://localhost
```

Expected result:

```text
HTTP/1.1 200 OK
Server: nginx/...
Content-Type: text/html
```

### 4. Verify the public endpoint

From PowerShell:

```powershell
Invoke-WebRequest http://<PUBLIC_IP> -UseBasicParsing
```

or:

```powershell
curl.exe -i http://<PUBLIC_IP>
```

A successful deployment returns HTTP `200 OK` and the React application's HTML.

The same endpoint can be opened directly in a browser:

```text
http://<PUBLIC_IP>
```

### 5. Backend health verification

The Product Service exposes a health endpoint:

```powershell
curl.exe -i http://localhost:3002/health
```

Expected response:

```json
{"service":"Product Service","status":"OK","port":"3002"}
```

The products API is available at `/api/products`:

```powershell
curl.exe -i http://localhost:3002/api/products
```

An empty product collection is valid for a new deployment; the response still confirms that the service endpoint is reachable.

## Assignment Requirement Mapping

| Requirement | Implementation / Evidence |
|---|---|
| Five Dockerfiles | User, Product, Cart, Order and Frontend Dockerfiles |
| Local image build | Five application images built from the service directories |
| Docker Hub publishing | Five versioned images under `raviveera2305` |
| VPC | Terraform-managed AWS VPC |
| Public subnet | Terraform-managed public subnet and internet routing |
| EC2 instance | Terraform-managed Ubuntu EC2 instance |
| Frontend HTTP access | Security Group allows TCP 80 |
| Internal service communication | Docker network with service ports 3001–3004 |
| Docker installation | EC2 `user_data.sh` |
| Image deployment | Docker Hub pulls in `user_data.sh` |
| Container startup | Docker run commands in `user_data.sh` |
| Public frontend | React application served through Nginx on port 80 |
| Backend verification | Container status, health endpoint and API response |
| Terraform outputs | Instance ID, public IP, public DNS and frontend URL |

## Evidence & Screenshot Index

The deployment evidence is maintained under `screenshots/`. Each screenshot is named according to the stage it documents so that the implementation can be reviewed in sequence without relying on terminal history.

| # | Evidence | Screenshot |
|---:|---|---|
| 01 | GitHub repository and project submission baseline | [`01-github-repository.png`](screenshots/01-github-repository.png) |
| 02 | Application and repository structure | [`02-project-structure.png`](screenshots/02-project-structure.png) |
| 03 | Docker environment / local setup | [`03-docker-environment.png`](screenshots/03-docker-environment.png) |
| 04 | User Service Dockerfile | [`04-user-service-dockerfile.png`](screenshots/04-user-service-dockerfile.png) |
| 05 | Product Service Dockerfile | [`05-product-service-dockerfile.png`](screenshots/05-product-service-dockerfile.png) |
| 06 | Cart Service Dockerfile | [`06-cart-service-dockerfile.png`](screenshots/06-cart-service-dockerfile.png) |
| 07 | Order Service Dockerfile | [`07-order-service-dockerfile.png`](screenshots/07-order-service-dockerfile.png) |
| 08 | Frontend Dockerfile | [`08-frontend-dockerfile.png`](screenshots/08-frontend-dockerfile.png) |
| 09 | Application Docker images built successfully | [`09-docker-images-built.png`](screenshots/09-docker-images-built.png) |
| 10 | E-commerce containers running together | [`10-all-ecommerce-containers-running.png`](screenshots/10-all-ecommerce-containers-running.png) |
| 11 | Docker network and container connectivity setup | [`11-ecommerce-network-containers.png`](screenshots/11-ecommerce-network-containers.png) |
| 12 | Terraform apply completion and deployment outputs | [`12-terraform-apply-completed-outputs.png`](screenshots/12-terraform-apply-completed-outputs.png) |
| 13 | EC2 host with application containers running | [`13-ec2-docker-containers-running.png`](screenshots/13-ec2-docker-containers-running.png) |
| 14 | Successful SSH connection to the EC2 instance | [`14-ec2-ssh-connection-success.png`](screenshots/14-ec2-ssh-connection-success.png) |
| 15 | Docker containers running on EC2 | [`15-docker-containers-running.png`](screenshots/15-docker-containers-running.png) |
| 16 | Frontend HTTP response verified from the host | [`16-frontend-container-http-verified.png`](screenshots/16-frontend-container-http-verified.png) |
| 17 | Public EC2 IP returning HTTP 200 | [`17-frontend-public-ip-http-200.png`](screenshots/17-frontend-public-ip-http-200.png) |
| 18 | E-commerce frontend accessible in a browser | [`18-ecommerce-frontend-browser.png`](screenshots/18-ecommerce-frontend-browser.png) |

### Evidence flow

The evidence follows the same order as the implementation:

```text
Application structure
        ↓
Dockerfiles and local container build
        ↓
Docker network and running containers
        ↓
Terraform infrastructure deployment
        ↓
EC2 access and container verification
        ↓
Frontend HTTP verification
        ↓
Public application access
```

This provides a direct audit trail from source configuration through infrastructure provisioning and final application accessibility.

> **Submission note:** Keep the screenshot filenames unchanged. The links above are relative repository links and are intended to remain valid when the evidence package is viewed directly from GitHub.

## Cleanup

When the assignment environment is no longer required, destroy the Terraform-managed AWS resources to avoid unnecessary charges:

```powershell
cd terraform
terraform destroy
```

Review the resources and enter `yes` when prompted.

## Deployment Notes

- The EC2 public IP is not permanent unless an Elastic IP is used.
- `terraform.tfvars` contains environment-specific deployment values and should remain outside source control when appropriate.
- Terraform state files should not be committed to the repository.
- Private keys must never be committed.
- Application secrets should be supplied through environment variables or a secrets-management service for production deployments.
- Backend and database ports should remain private unless external access is explicitly required.

## License

See [LICENSE](LICENSE).
