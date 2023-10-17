terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }

  required_version = ">= 1.3.0"
}

/**
 * set the following env vars so that kubernetes provider will get authenticated before apply:

*/
provider "kubernetes" {


  cluster_ca_certificate = ""
  host                   = ""

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "--region", "region-name", "get-token", "--cluster-name", "cluster-name"]
    command     = "aws"
  }

}
