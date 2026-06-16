variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "portfolio"
}

variable "container_port" {
  description = "Port exposé par le conteneur"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU alloué à la tâche ECS (en unités)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Mémoire allouée à la tâche ECS (en Mo)"
  type        = number
  default     = 512
}
