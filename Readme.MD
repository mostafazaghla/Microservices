# Deployment Steps for Python Microservice on Kubernetes

## Overview
This document outlines the steps followed to deploy a Python Flask microservice on a Kubernetes cluster using Azure, Docker, and GitHub Actions. The process includes containerization, infrastructure provisioning, service exposure, and CI/CD automation.

---

## **Steps Taken**

### **1. Clone the Repository**
Clone the microservice repository from GitHub:
```bash
git clone https://github.com/sameh-Tawfiq/Microservices
cd Microservices
```

### **2. Dockerize the Application**
Create a `Dockerfile` to containerize the Flask application:

```Dockerfile
FROM python:3.9-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

Build and run the Docker image locally:
```bash
docker build -t pwc-microservice .
docker run -p 5000:5000 pwc-microservice
```

### **3. Provision a Kubernetes Cluster on Azure using Terraform**
Create a Terraform configuration file (`main.tf`) to provision the cluster:

```hcl
provider "azurerm" {
  features = {}
}

resource "azurerm_kubernetes_cluster" "my_cluster" {
  name                = "myK8sCluster"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaksdns"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}
```

Deploy the cluster using Terraform:
```bash
terraform init
terraform apply
```

### **4. Deploy the Microservice on Kubernetes**
Create `deployment.yaml` and `service.yaml` files:

#### `deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pwc-microservice
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pwc-microservice
  template:
    metadata:
      labels:
        app: pwc-microservice
    spec:
      containers:
      - name: flask-container
        image: zzlolo123/pwc-microservice:latest
        ports:
        - containerPort: 5000
```

#### `service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: pwc-microservice
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 5000
  selector:
    app: pwc-microservice
```

Apply the configurations:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### **5. Expose the Service to the Internet**
- Ensure the `LoadBalancer` service is configured correctly in `service.yaml`.
- Use annotations to specify the type (`external` or `internal`) based on the requirement.

### **6. Implement CI/CD Pipeline with GitHub Actions**
Create `.github/workflows/deploy.yml`:

```yaml
name: Build, Scan, and Deploy to Docker Hub

on:
  push:
    branches:
      - main

jobs:
  build-deploy:
    runs-on: self-hosted  # Specify local runner

    env:
      IMAGE_NAME: "zzlolo123/pwc-microservice"

    steps:
    - name: Checkout Code
      uses: actions/checkout@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build Docker Image with Alpine
      run: |
        docker build -f Dockerfile.alpine -t $IMAGE_NAME:latest .

    - name: Scan Docker Image with Trivy
      uses: aquasecurity/trivy-action@v0.11.0
      with:
        image-ref: ${{ env.IMAGE_NAME }}:latest
        format: "table"
        exit-code: "0"
        severity: "HIGH,CRITICAL"

    - name: Push Docker Image
      run: |
        docker push $IMAGE_NAME:latest

    - name: Deploy to AKS
      run: |
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml
```

### **7. Secure Credentials with GitHub Secrets**
- Store sensitive information such as Docker Hub credentials in **GitHub Secrets**.
- Access them in workflows using `secrets.DOCKER_USERNAME` and `secrets.DOCKER_PASSWORD`.

### **8. Verify Deployment**
1. Check the Kubernetes pods and services:
   ```bash
   kubectl get pods
   kubectl get svc
   ```
2. Access the service using the external IP from the load balancer:
   ```bash
   kubectl get service pwc-microservice
   ```
   The external IP will be listed under the `EXTERNAL-IP` column. Use this IP to access the service.




