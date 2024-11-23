variable "kubeconfig" {
  description = "Kubeconfig details to connect to the Kubernetes cluster."
  type = object({
    host                   = string
    cluster_ca_certificate = string
    cluster_name           = string
  })
}

variable "release_name" {
  description = "The name of the Helm release."
  type        = string
}

variable "chart_repository" {
  description = "The repository URL of the Helm chart."
  type        = string
}

variable "chart_name" {
  description = "The name of the Helm chart to deploy."
  type        = string
}

variable "chart_version" {
  description = "The version of the Helm chart."
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy the chart into."
  type        = string
}

variable "values" {
  description = "A list of values.yaml files or raw values to pass to the chart."
  type        = list(string)
  default     = []
}
