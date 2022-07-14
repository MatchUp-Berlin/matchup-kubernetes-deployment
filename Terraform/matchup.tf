
resource "kubernetes_namespace" "matchup" {
  metadata {
    name = "matchup"
  }
}

/* Deployment */
resource "kubernetes_deployment" "matchup" {
  metadata {
    name      = "matchup"
    namespace = "matchup"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "matchup"
      }
    }
    template {
      metadata {
        labels = {
          app = "matchup"
        }
      }
      spec {
        container {
          image = "mitchellryansmith/matchup:latest"
          name  = "matchup"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

/* Service */
resource "kubernetes_service" "matchup" {
  metadata {
    name      = "matchup"
    namespace = "matchup"
  }
  spec {
    selector = {
      app = "matchup"
    }
    type = "NodePort"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}
