variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "astrolog-function"
}

variable "python_runtime" {
  description = "Python runtime version"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "layer_package_path" {
  description = "Path to the Astrolog layer package (tar.gz file)"
  type        = string
  default     = "../out/astrolog-bin-7.50.tar.gz"
}

variable "enable_function_url" {
  description = "Enable Lambda Function URL for direct HTTP invocation"
  type        = bool
  default     = false
}
