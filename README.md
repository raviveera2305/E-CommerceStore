# E-Commerce Store

Dockerized Node.js microservices deployed on AWS EC2 with Terraform.

This repository contains a multi-service e-commerce application built with React, Node.js/Express, MongoDB, Docker, Docker Hub and Terraform. The deployment was completed as part of the Hero Vired Skill Test 3 requirement to deploy a multi-service Node.js application using Docker and Terraform.

## Overview

The application is split into a React frontend and four backend services. Each service runs in its own Docker container. MongoDB runs as a separate container on the same Docker network.

| Component | Port | Purpose |
|---|---:|---|
| Frontend / Nginx | 80 | Public web application |
| User Service | 3001 | User and authentication operations |
| Product Service | 3002 | Products and categories |
| Cart Service | 3003 | Shopping cart operations |
| Order Service | 3004 | Order and checkout operations |
| MongoDB | 27017 | Application data store |

The services communicate over the Docker network `ecommerce-network`. The frontend is the only service intended for public HTTP access.

## Architecture

```text
                              Internet
                                  |
                              TCP :80
                                  |
                                  v
                    +----------------------------+
                    |        AWS EC2 / Ubuntu    |
                    |                            |
                    |       Docker Engine        |
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

**Application**

- React
- Node.js 20
- Express.js
- MongoDB / Mongoose
- REST APIs
- JWT authentication

**Containerization**

- Docker
- Docker Hub
- Docker network
- Nginx for the frontend container

**Infrastructure**

- AWS EC2
- AWS VPC
- Public subnet
- Internet Gateway
- Security Groups
- Terraform
- Ubuntu Linux

**Region:** `ap-south-1` (Mumbai)

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

Terraform state, variable files containing environment-specific values, credentials and private keys are intentionally excluded from source control.

## Docker Images

The application images are published under the Docker Hub account `raviveera2305`.

```text
raviveera2305/ecommerce-user-service:1.0
raviveera2305/ecommerce-product-service:1.0
raviveera2305/ecommerce-cart-service:1.0
raviveera2305/ecommerce-order-service:1.0
raviveera2305/ecommerce-frontend:1.0
```

MongoDB uses the official `mongo:7` image.

## Building the Images

Build and tag each service from the repository root.

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

Terraform is responsible for the AWS infrastructure. Application image creation and Docker Hub publishing are handled separately from Terraform.

### Prerequisites

Install and configure:

- AWS CLI
- Terraform 1.6 or later
- Docker
- An AWS account with permission to create the required EC2/VPC resources

Configure the AWS CLI profile used by the project:

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
| `.terraform.lock.hcl` | Provider dependency lock file |

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

### Review the deployment

```powershell
terraform plan
```

### Create the infrastructure

```powershell
terraform apply
```

Review the plan and enter `yes` when prompted.

### View deployment outputs

```powershell
terraform output
```

The outputs include:

```text
frontend_url
instance_id
public_dns
public_ip
```

The public IP is assigned by AWS and can change when the EC2 instance is recreated. Use the current value returned by Terraform instead of hard-coding an address in deployment scripts or documentation.

## EC2 Bootstrap

The EC2 instance uses `user_data.sh` during first boot. The script:

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
13. Prints the running containers.

The containers use Docker DNS names rather than public IP addresses for service-to-service communication. For example:

```text
mongodb://ecommerce-mongodb:27017/ecommerce_products
http://ecommerce-product-service:3002
http://ecommerce-cart-service:3003
http://ecommerce-user-service:3001
```

## Security Group

The EC2 security group is configured for the deployment requirements:

| Rule | Source | Purpose |
|---|---|---|
| TCP 80 | `0.0.0.0/0` | Public frontend access |
| TCP 22 | Administrator CIDR | SSH administration |

The backend services and MongoDB are intended to communicate through the private Docker network. They do not need to be publicly reachable for the application to work.

For a production deployment, SSH access should be restricted further and secrets should be supplied through a dedicated secrets-management solution rather than being embedded in startup scripts.

## Deployment Verification

### Check the EC2 instance

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

### Check the containers

SSH to the instance and run:

```bash
docker ps
```

A completed deployment runs:

```text
ecommerce-frontend
ecommerce-user-service
ecommerce-product-service
ecommerce-cart-service
ecommerce-order-service
ecommerce-mongodb
```

### Verify the frontend from the EC2 host

```bash
curl -I http://localhost
```

Expected result:

```text
HTTP/1.1 200 OK
Server: nginx/...
Content-Type: text/html
```

### Verify the public endpoint

From PowerShell:

```powershell
Invoke-WebRequest http://<PUBLIC_IP> -UseBasicParsing
```

or:

```powershell
curl.exe -i http://<PUBLIC_IP>
```

A successful deployment returns HTTP `200 OK` and the React application's HTML.

The application can also be opened directly in a browser at:

```text
http://<PUBLIC_IP>
```

### Backend health check

The Product Service exposes a health endpoint:

```powershell
curl.exe -i http://localhost:3002/health
```

Expected response:

```json
{"service":"Product Service","status":"OK","port":"3002"}
```

The products API is available under `/api/products`:

```powershell
curl.exe -i http://localhost:3002/api/products
```

A new deployment can legitimately return an empty product collection while still confirming that the service and MongoDB connection are available.

## Assignment Requirement Mapping

| Requirement | Implementation |
|---|---|
| Five Dockerfiles | Dockerfiles for User, Product, Cart, Order and Frontend services |
| Local image build | Docker build performed for each service |
| Docker Hub publishing | Five versioned images under `raviveera2305` |
| VPC | Terraform-managed VPC |
| Public subnet | Terraform-managed subnet with internet routing |
| EC2 | Terraform-managed Ubuntu EC2 instance |
| Frontend HTTP | Security Group allows TCP 80 |
| Internal services | Docker network with ports 3001–3004 |
| Docker installation | EC2 `user_data.sh` |
| Image pull | Docker Hub pulls in `user_data.sh` |
| Container startup | Docker run commands in `user_data.sh` |
| Public application | React/Nginx frontend on port 80 |
| Backend verification | Container status and service health/API checks |
| Terraform outputs | Instance ID, public IP, public DNS and frontend URL |

## Evidence

The project includes deployment evidence under `screenshots/`. The screenshots document the main implementation and verification stages, including the repository/application setup, Docker configuration, Terraform deployment, EC2 deployment, running containers and public application access.

For an evaluation, the screenshots should be read together with the corresponding Terraform files and the deployment output recorded in this README.

## Cleanup

When the assignment environment is no longer required, destroy Terraform-managed infrastructure to avoid unnecessary AWS charges:

```powershell
cd terraform
terraform destroy
```

Review the resources and enter `yes` when prompted.

Terraform state and local environment files should remain outside source control.

## Notes for Future Deployments

- The EC2 public IP is not permanent unless an Elastic IP is used.
- `terraform.tfvars` is environment-specific and should not be committed when it contains local IP addresses or other deployment values.
- Private keys must never be committed to the repository.
- Application secrets should be supplied through environment variables or a secrets-management service in a production environment.
- Backend and database ports should remain private unless external access is explicitly required.

## License

See [LICENSE](LICENSE).
