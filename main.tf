terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configura o DigitalOcean Provider
provider "digitalocean" {
  # O token é a chave que faz a comunicação entre o plugin, provider e minha conta do cloud provider
  token = var.do_token
}

# Esse nome l8s_* é do recurso do projeto, declaração do código, sempre que for referenciar esse recurso é esse nome
resource "digitalocean_kubernetes_cluster" "k8s_iniciativa" {
  # Nome do Cluster no DigitalOcean
  name = var.k8s_name
  # A região no caso está setada para New York   
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.22.8-do.1"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  # Aqui devemos colocar no ID o nome do recurso do projeto. Não do Cluster
  cluster_id = digitalocean_kubernetes_cluster.k8s_iniciativa.id

  name       = "premium"
  size       = "s-4vcpu-8gb"
  node_count = 2
}

variable "do_token" {}
variable "k8s_name" {}
variable "region" {}

output "kube_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s_iniciativa.endpoint
}

resource "local_file" "kube_config" {
  content  = digitalocean_kubernetes_cluster.k8s_iniciativa.kube_config.0.raw_config
  filename = "kube_config.yaml"
}
