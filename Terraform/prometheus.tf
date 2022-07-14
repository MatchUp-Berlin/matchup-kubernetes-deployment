resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

/* Prometheus Config Map */
resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "prometheus"
  }
  data = {
    "prometheus.yml" = "${file("${path.module}/prometheus.yml")}"
  }
}

/* Prometheus Cluster Role */
resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "prometheus"
  }
}

/* Prometheus Stateful Set */
resource "kubernetes_stateful_set" "prometheus" {
  metadata {
    namespace = "prometheus"
    name      = "prometheus"
  }
  spec {
    pod_management_policy = "OrderedReady"
    replicas              = 1
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    service_name = "prometheus"
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        service_account_name = "default"
        container {
          name  = "prometheus"
          image = "prom/prometheus:latest"
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }
          port {
            container_port = 9090
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = "prometheus"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "prometheus-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

/* Prometheus Service */
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "prometheus"
  }
  spec {
    selector = {
      app = "prometheus"
    }
    type = "NodePort"
    port {
      port        = 9090
      target_port = 9090
    }
  }
}
