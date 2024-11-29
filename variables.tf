variable "tags" {
  description = "Defaults tags all resources"
  type = map(string)
  default = {
  }
}

variable "kms_for_lambda" {
  description = "KMS alias use in lambda"
  type = string
}


variable "kms_for_cloudwatch" {
  description = "KMS alias use in cloudwatch"
  type = string
}
