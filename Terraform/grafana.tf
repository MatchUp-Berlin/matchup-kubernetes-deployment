
resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

/* Grafana Deployment */
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "grafana"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }
      spec {
        container {
          image = "grafana/grafana:latest"
          name  = "grafana"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

/* Grafana Service */
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "grafana"
  }
  spec {
    selector = {
      app = "grafana"
    }
    type = "NodePort"
    port {
      port        = 8080
      target_port = 3000
    }
  }
}
