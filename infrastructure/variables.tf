variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "image_uri" {
  description = "URI de la imagen del contenedor en ECR" 
  type        = string
  default     = "dummy" # El pipeline inyectará el valor real en tiempo de ejecución
}

