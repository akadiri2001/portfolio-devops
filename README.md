# Portfolio DevOps Infrastructure

> Containerization, Infrastructure as Code & CI/CD pipeline for my personal portfolio.

## Stack
- **Docker** — multi-stage build with nginx-unprivileged
- **AWS ECS Fargate** — serverless container hosting
- **AWS ECR** — private container registry
- **Terraform** — infrastructure as code
- **GitHub Actions** — CI/CD pipeline

## Architecture
<img width="256" height="419" alt="image" src="https://github.com/user-attachments/assets/5eaa745b-a10f-45a5-af9b-47155ab1f053" />


## Quick start
```bash
docker build -t portfolio:dev .
docker run --rm -p 8080:8080 portfolio:dev
```

## Infrastructure
```bash
cd infra/
terraform init
terraform plan
terraform apply
```

## Destroy (important — avoid AWS charges)
```bash
cd infra/
terraform destroy
```
