variable "vpc_availability_zones" {
  type        = list(string)
  description = "Available Zones"
  default     = ["us-east-1a", "us-east-1b"]
}