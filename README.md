# Kubernetes Application Deployment with GitOps, CI/CD & Automated Load Testing (K6)
---
## Project Overview

This project demonstrates a production-grade CI/CD pipeline with integrated performance testing for deploying a cloud-native web application on Kubernetes using GitOps principles.
The solution automates the full application lifecycle, including container image build, security validation, Kubernetes deployment, and automated load testing using K6.
It simulates real-world DevOps scenarios such as deployment failures, insecure configurations, and performance bottlenecks, while ensuring the application is continuously validated through automated smoke, load, and stress testing.

---
## Problem Statement

Modern application delivery pipelines often lack integrated performance testing and security validation, leading to unreliable deployments and undetected performance issues.
Teams commonly face challenges such as:
- Lack of automated performance testing before and after deployment
- Security misconfigurations in Dockerfiles and Kubernetes manifests
- Uncontrolled traffic flow within Kubernetes clusters
- Manual and inconsistent deployment processes

Traditional approaches introduce risks, including:
- Deployment of vulnerable or misconfigured applications
- Performance degradation under load
- Lack of visibility into application reliability
- Inefficient and error-prone testing processes
---
## Problem Solution

This project provides a cloud-native DevOps solution that integrates CI/CD, GitOps, security scanning, and automated performance testing into a unified workflow.
- Containerization using Docker
- CI/CD automation with GitHub Actions
- Security scanning with Trivy and Checkov
- GitOps deployment using Argo CD
- Kubernetes-native load testing with K6
- Network policies for secure traffic control
- Scheduled testing using Kubernetes 

The  solution ensures that applications are secure, tested, and production-ready before and after deployment, improving reliability, performance, and operational efficiency.
## Key Features
- Automated CI/CD Pipeline: GitHub Actions builds Docker images and performs security and compliance checks before deployment.
- Integrated Security Scanning: Trivy scans container images for vulnerabilities, while Checkov validates Kubernetes manifests and Dockerfiles against best practices.
- GitOps Deployment Model: Argo CD continuously synchronizes Kubernetes manifests from GitHub, ensuring a declarative and automated deployment process.
- Kubernetes-Native Load Testing (K6): K6 is deployed within the cluster to perform real-time performance testing against the application.
- Network Policy Enforcement: Kubernetes Network Policies restrict traffic, allowing only K6 to communicate with the application for controlled testing.
- Automated Testing with CronJobs: Scheduled performance tests run automatically using Kubernetes CronJobs.
- Cloud-Native Architecture: Fully designed for Kubernetes environments with scalability, security, and resilience in mind

---
📊 Architecture Diagram

![archetectural diagram](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Blank%20diagram.jpeg)

Infrastructure Layer
- Docker Hub for container images
- Kubernetes namespaces for isolation
- CI/CD & GitOps Layer
- GitHub Actions builds and pushes:
- Web application image
- K6 testing image
- Argo CD syncs GitHub repo to Kubernetes cluster
- Testing Layer
- K6 deployed inside Kubernetes
- Runs load, stress, and smoke tests
- Sends traffic to the application service
---
  ## 🧱 Technical Architecture

| Technology         | Purpose                  | Key Benefit                          |
|------------------|------------------------|--------------------------------------|
| TypeScript        | Application Development | Type safety and maintainability      |
| Node.js           | Backend Runtime         | Scalable server execution            |
| React / Vite      | Frontend                | Fast UI development                  |
| Docker            | Containerization        | Consistent environments              |             |
| GitHub Actions    | CI/CD                   | Automated build & deploy             |
| Argo CD           | GitOps                  | Declarative deployments              |
| Kubernetes        | Orchestration           | Scalability & resilience             |
| K6                | Performance Testing     | Load & stress testing                |
---
## Workflow
- Developer pushes code to GitHub
- GitHub Actions builds:
- Web app Docker image
- K6 test Docker image
- Images are pushed to Docker Hub
- Argo CD syncs manifests to Kubernetes
- Application is deployed in cluster
- K6 runs performance tests
- Results validate application stability
---

## CI Pipeline – GitHub Actions (Build & Push to Docker Hub)
This section describes how the CI pipeline is implemented using GitHub Actions to automate the build, test, and deployment of both the application and the K6 testing image. The CI pipeline is triggered automatically when code is pushed to the repository.
It performs the following steps:
- Check out the source code from GitHub
- Build a Docker image for the web application
- Build Docker image for K6 testing tool
- Run security and validation checks
- Authenticate with Docker 

  ```
      name: Build, Test, and Push Docker Images
    
    on:
      push:
        branches: [ main ]
    
    env:
      IMAGE_NAME: rukevweubio/mycluster-app
      IMAGE_TAG: v3
      IMAGE_TEST_NAME: rukevweubio/my-load-test
      IMAGE_TEST_TAG: v2
    
    jobs:
      build_test_push:
        runs-on: ubuntu-latest
    
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
    
       
          - name: Login to Docker Hub
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.DOCKER_USERNAME }}
              password: ${{ secrets.DOCKER_PASSWORD }}
    
         
          - name: Build main app image
            uses: docker/build-push-action@v5
            with:
              context: .
              load: true   
              tags: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
    
       
          - name: Build load test image
            uses: docker/build-push-action@v5
            with:
              context: ./k6
              load: true
              tags: ${{ env.IMAGE_TEST_NAME }}:${{ env.IMAGE_TEST_TAG }}
    
    
          - name: Scan main image with Trivy
            uses: aquasecurity/trivy-action@master
            with:
              image-ref: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
              severity: CRITICAL,HIGH
              exit-code: 0
    
         
          - name: Scan load test image with Trivy
            uses: aquasecurity/trivy-action@master
            with:
              image-ref: ${{ env.IMAGE_TEST_NAME }}:${{ env.IMAGE_TEST_TAG }}
              severity: CRITICAL,HIGH
              exit-code: 0
    
          - name: Push main image
            if: success()
            run: docker push ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
    
          - name: Push load test image
            if: success()
            run: docker push ${{ env.IMAGE_TEST_NAME }}:${{ env.IMAGE_TEST_TAG }}
    
      checkov_scan:
        runs-on: ubuntu-latest
        needs: build_test_push
    
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
    
         
          - name: Scan main Dockerfile
            uses: bridgecrewio/checkov-action@master
            with:
              directory: .
              framework: dockerfile
    
        
          - name: Scan k6 Dockerfile
            uses: bridgecrewio/checkov-action@master
            with:
              directory: ./k6
              framework: dockerfile
    
        
          - name: Scan Kubernetes app manifests
            uses: bridgecrewio/checkov-action@master
            with:
              directory: ./apps
              framework: kubernetes
              skip_check: CKV_K8S_43,CKV_K8S_38,CKV_K8S_40,CKV_K8S_15,CKV2_K8S_6
    
          - name: Scan load test manifests
            uses: bridgecrewio/checkov-action@master
            with:
              directory: ./k6/cronjob
              framework: kubernetes
              skip_check: CKV_K8S_43,CKV_K8S_38,CKV_K8S_40,CKV_K8S_15,CKV2_K8S_6
    
          - name: Scan load test manifests
            uses: bridgecrewio/checkov-action@master
            with:
              directory: ./k6/loadtest  
              framework: kubernetes
              skip_check: CKV_K8S_43,CKV_K8S_38,CKV_K8S_40,CKV_K8S_15,CKV2_K8S_6
  ```
![Gitaction workflow](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2018.07.45.png)


##  Argo CD Installation & Namespace Setup
After provisioning the Kubernetes cluster  the next step was to configure the GitOps control plane using Argo CD and prepare isolated namespaces for workloads.
Step 1: Create Kubernetes Namespaces
To properly organize cluster resources, two main namespaces were created:
argocd → for Argo CD (GitOps control plane)
dev → for the application workloads (web app + K6 testing)

```
# Create Argo CD namespace
kubectl create namespace argocd

# Create application namespace
kubectl create namespace dev
kubectl create namespace my-app  #  for application

### install argocd on the cluster

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.
```
![argocd installtion](
