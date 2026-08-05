variable "website_name" {
  description = "The name of the website"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket that will host website"
  type        = string
}

variable "index_document" {
  description = "The website for the index document (e.g., home page)"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The website for the error document (e.g., 404 page)"
  type        = string
  default     = "index.html"
}

variable "website_aliases" {
  description = "The list of aliases (alternate domain names) for the website"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate for the website"
  type        = string
}
