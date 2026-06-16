# Portfolio DevOps Infrastructure

> Containerization, Infrastructure as Code & CI/CD pipeline for my personal portfolio.

## Stack
- **Docker** — multi-stage build with nginx-unprivileged
- **AWS ECS Fargate** — serverless container hosting
- **AWS ECR** — private container registry
- **Terraform** — infrastructure as code
- **GitHub Actions** — CI/CD pipeline

## Architecture
_Schéma à venir_

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
