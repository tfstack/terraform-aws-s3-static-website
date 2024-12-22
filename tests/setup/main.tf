terraform {
  required_version = ">= 1.0"
}

# Generate a random string as suffix
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Output suffix for use in tests
output "suffix" {
  value = random_string.suffix.result
}
