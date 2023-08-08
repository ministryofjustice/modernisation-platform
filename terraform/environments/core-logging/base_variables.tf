variable "networking" {
  type = list(any)
  default = [
    {
      "business-unit": "",
      "set": "",
      "application": "core-logging"
    }
  ]
}