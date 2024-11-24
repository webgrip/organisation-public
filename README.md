# WebGrip Organisation Public Repository

Welcome to the public repository for the WebGrip Organisation.

You will find here the base structure of the organisation, such as domains, groups, and users needed to build the rest.


#### Requirements
- AWS CLI
- Kubectl
- Helm
- Terraform
- 


```
aws configure
aws eks update-kubeconfig --name staging-eks-cluster --region <region-name>

Traefik CRDS: https://raw.githubusercontent.com/traefik/traefik/v3.1/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

helm package ops/helm/traefik-chart
helm template traefik ops/helm/traefik-chart --namespace traefik
helm upgrade traefik ops/helm/traefik-chart/traefik-chart-1.0.0.tgz --namespace traefik --create-namespace
```
