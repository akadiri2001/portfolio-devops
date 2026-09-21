# Portfolio DevOps Infrastructure

[![Deploy](https://github.com/akadiri2001/portfolio-devops/actions/workflows/deploy.yml/badge.svg)](https://github.com/akadiri2001/portfolio-devops/actions/workflows/deploy.yml)

> Containerization, Infrastructure as Code and CI/CD pipeline for my personal portfolio.
> A push to `main` builds the image, pushes it to a private registry and rolls out a new
> version on ECS Fargate — no manual step in between.

## Architecture

<img width="256" height="419" alt="Architecture diagram" src="https://github.com/user-attachments/assets/5eaa745b-a10f-45a5-af9b-47155ab1f053" />

```
GitHub push (main)
  └─ GitHub Actions runner
       ├─ checkout infra repo + private source repo
       ├─ docker build  ──────────────►  ECR (private registry)
       └─ aws ecs update-service
            └─ ECS Fargate task  ◄── pulls image
                 └─ ALB (public, :80)  ──►  nginx :8080
```

## Stack

| Layer | Choice | Why |
|---|---|---|
| Image | Docker multi-stage, `nginx-unprivileged` | Node toolchain stays in the build stage; the runtime image ships only static assets and runs as UID 101 on port 8080 — no root, no capability to bind privileged ports |
| Registry | AWS ECR | Private, with scan-on-push enabled |
| Runtime | AWS ECS Fargate | No EC2 instance to patch or size; the task definition *is* the deployment unit |
| Network | VPC, 2 public subnets, ALB | Two AZs because an ALB requires at least two; no NAT gateway, which is the single largest cost driver in this kind of setup |
| IaC | Terraform, S3 backend | Remote state with locking and encryption, so the state survives the machine it was applied from |
| CI/CD | GitHub Actions | Build, push and rollout on every push to `main` |

## Repository layout

This repository holds the **infrastructure and delivery chain**. The portfolio
application itself (React 19 + Vite + TypeScript) lives in a separate private
repository, `akadiri2001/portefolio`.

The pipeline reconciles the two: it checks out both, assembles a single build
context, and builds from there. This keeps the application source private while
the infrastructure work stays public and readable.

```
.
├── .github/workflows/deploy.yml   # the pipeline
├── Dockerfile                     # multi-stage build
├── nginx.conf                     # SPA fallback + asset caching
├── docker-compose.yml             # local run
└── infra/                         # Terraform: VPC, ALB, ECR, ECS, IAM, logs
```

## CI/CD pipeline

Triggered on every push to `main`, and manually via `workflow_dispatch`.

1. **Checkout infra repo** — Dockerfile, nginx config
2. **Checkout portfolio source** — the private repo, via a fine-grained read-only token
3. **Assemble build context** — merge both into one directory
4. **Configure AWS credentials** / **Login to ECR**
5. **Build, tag & push** — tagged with both the commit SHA (traceability) and `latest`
6. **Deploy to ECS** — `update-service --force-new-deployment`
7. **Wait for service stability** — the job fails if ECS rolls back, instead of
   reporting a green build on a broken deployment

### Required secrets

| Secret | Purpose |
|---|---|
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Push to ECR, update the ECS service |
| `PORTFOLIO_REPO_TOKEN` | Fine-grained PAT, `Contents: read` on the source repository only |

## Local development

The Dockerfile expects the application source in the build context, so the two
repositories have to be assembled first — exactly what the pipeline does:

```bash
git clone https://github.com/akadiri2001/portfolio-devops.git
git clone https://github.com/akadiri2001/portefolio.git

cp portfolio-devops/{Dockerfile,nginx.conf,.dockerignore} portefolio/
cd portefolio

docker build -t portfolio:dev .
docker run --rm -p 8080:8080 portfolio:dev
```

Then open http://localhost:8080.

## Infrastructure

### First apply — order matters

The ECS task definition references `portfolio:latest`. If the service is created
before any image exists, its tasks fail to pull and crash-loop. So the registry
goes up first:

```bash
cd infra/
terraform init
terraform apply -target=aws_ecr_repository.portfolio
```

Push an initial image (see *Local development*, then `docker push`), and only
then bring up the rest:

```bash
terraform apply
terraform output alb_dns_name
```

### Teardown — important

An ALB and a Fargate task are billed by the hour whether or not they serve
traffic. This stack is meant to be brought up on demand, not left running:

```bash
cd infra/
terraform destroy
```

The S3 state bucket is intentionally not managed by Terraform and survives the
teardown.

## Evidence

Screenshots of the running stack live in [`screen/`](screen/): the green
pipeline run, the image in ECR, the ECS service, the healthy ALB target and the
live site.

## Roadmap

- **Replace static AWS keys with OIDC** — a federated IAM role assumed by the
  workflow, so no long-lived credential is stored in GitHub at all
- **Register a new task definition revision per deploy** instead of relying on
  the `latest` tag, giving real rollback and per-commit traceability
- **ECR lifecycle policy** to cap image retention
- **Deployment circuit breaker** with automatic rollback on failed rollout
