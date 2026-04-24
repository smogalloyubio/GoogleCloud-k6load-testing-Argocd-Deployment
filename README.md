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
    
      
  ```
![Gitaction workflow](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2018.07.45.png)
---
Argo CD is used as the GitOps controller for continuous deployment.

- Install Argo CD in Kubernetes cluster
- Create namespaces:
- argocd → GitOps control plane
- dev → application + K6 workloads
- Connect Argo CD CLI to cluster
- Login using admin credentials
- Register GitHub repository
- Create application pointing to manifests
- Enable automatic sync
Result:
Any GitHub change automatically updates the Kubernetes cluster.
```
# Download Argo CD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Make it executable
chmod +x argocd

# Move to system path
sudo mv argocd /usr/local/bin/

argocd version --client
kubectl get svc argocd-server -n argocd
argocd login  localhost:port 
argocd login <ARGOCD_SERVER_IP> --username admin --password <INITIAL_PASSWORD> --insecure

kubectl get secret argocd-initial-admin-secret -n argocd \
-o jsonpath="{.data.password}" | base64 -d

Connect your GitHub repository to Argo CD.

argocd repo add https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment.git

This step tells Argo CD what to deploy and where.

argocd app create webapp \
--repo https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment.git
--path apps\
--dest-server https://kubernetes.default.svc \
--dest-namespace dev
--sync-option
--sync-policy 
argocd app sync webapp
argocd app get webapp

```
![argocd installtion](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2018.04.59.png)

![Argocd cli](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2016.48.28.png)

![argocd application](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2017.51.36.png)
----
## K6 Load Testing Setup with Argo CD
This section explains how K6 was installed, containerized, and deployed on the Kubernetes cluster using Argo CD (GitOps approach).
The goal is to run automated load, smoke, and stress tests inside the same cluster where the application is deployed
- Load testing the web application
- Stress testing API endpoints
- Running automated performance checks
- Validating system stability under traffic
In this project, K6 runs as a Kubernetes workload (Job / CronJob) managed by Argo CD.
Step 2: Build K6 Docker Image
First, the K6 test scripts are containerized using  docker image
```
FROM grafana/k6:0.51.0
WORKDIR /home/k6/scripts
COPY --chown=k6:k6 smoke.js .
COPY --chown=k6:k6 load.js .
COPY --chown=k6:k6 stress.js .
HEALTHCHECK --interval=30s --timeout=3s \
CMD k6 version || exit 1
USER k6
ENTRYPOINT ["k6"]

```

---
Step 3: Create Kubernetes Manifest for K6
K6 runs as a Kubernetes Job (or CronJob for repeated tests).
```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: k6-smoke-test-scheduled
  namespace: dev
spec:
  schedule: "*/2 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 10
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            role: k6-tester
        spec:
          securityContext:
            runAsNonRoot: true
            runAsUser: 10000
            seccompProfile:
              type: RuntimeDefault
          
          automountServiceAccountToken: false

          containers:
            - name: k6
              image: rukevweubio/my-load-test:v2
              imagePullPolicy: Always
              args: ["run", "smoke.js"]
              env:
                - name: BASE_URL
                  value: "http://my-app:3000"
              securityContext:
                allowPrivilegeEscalation: false
                readOnlyRootFilesystem: true
                capabilities:
                  drop:
                    - ALL
              resources:
                requests:
                  cpu: "100m"
                  memory: "64Mi"
                limits:
                  cpu: "250m"
                  memory: "128Mi"

          restartPolicy: OnFailure
```
---
Step 4: Example K6 Test Script
```
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://my-app:3000';

export const options = {
  vus: 2,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get(BASE_URL);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}
```
![argocd console](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2017.50.25.png)

![k6 load testing](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2017.52.54.png)


![k6 load testing](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2017.52.46.png)

![argocd k6 loading testing ](https://github.com/smogalloyubio/GoogleCloud-k6load-testing-Argocd-Deployment/blob/main/picture/Screenshot%202026-04-19%20at%2018.04.06.png)

## Kubernetes Network Policy (K6 → Application Traffic Control)
A Kubernetes NetworkPolicy is a security rule that controls:

- Which pods can talk to other pods
- Which namespaces are allowed to send traffic
- Which ports and protocols are permitted
In this project, it was used to enforce controlled traffic flow between the K6 testing environment and the application namespace.
Why was it used in this project by  default? Kubernetes allows all pods to communicate freely inside the cluster.
That is a security risk. So in this project, NetworkPolicy was implemented to:
-  Restrict traffic to only allowed sources
-  Ensure only K6 can access the application
-   block all other unwanted traffic inside the cluster
-  simulate real production-grade security controls
-   Ensure load testing traffic is controlled and measurable
----
## How it works in your setup
1. K6 runs in a separate namespace
dev namespace → application
k6 namespace → performance testing
This isolation ensures clean separation of workloads.

2. NetworkPolicy allows ONLY K6 traffic
The policy defines:
Ingress rules → who can access the app
Namespace selector → only K6 namespace is allowed
Pod selector → only specific app pods are reachable
Port control → only application port is exposed (e.g., 3000)

```
