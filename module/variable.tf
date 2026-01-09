variable "project_id" {
  default = "dev-project-482704"

}

variable "create_s3" {
  type = bool
  default = false

}

variable "names" {
  type = list(string)
  default = [""]
}

variable "randomize_suffix" {
  type        = bool
  description = "Whether to randomize the bucket suffix."
  default     = false
}

variable "network_name" {
  type = string
}