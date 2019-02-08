resource "helm_release" "vault" {
  name       = "${var.release_name}"
  chart      = "${var.chart_name}"
  repository = "${var.chart_repository}"
  version    = "${var.chart_version}"
  namespace  = "${var.chart_namespace}"

  values = [
    "${data.template_file.values.rendered}",
  ]
}

locals {
  vault_listener_adderss = "${var.vault_listener_address}:${var.service_port}"
  vault_cluster_address  = "${var.vault_listener_address}:${var.service_port + 1}"

  base_vault_config {
    listener "tcp" {
      address = "${local.vault_listener_adderss}"
      cluster = "${local.vault_cluster_address}"

      tls_prefer_server_cipher_suites = true
      tls_cipher_suites               = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA"
    }
  }
}

data "template_file" "values" {
  template = "${file("${path.module}/templates/values.yaml")}"

  vars {
    replica     = "${var.replica}"
    vault_image = "${var.vault_image}"
    vault_tag   = "${var.vault_tag}"

    consul_image                  = "${var.consul_image}"
    consul_tag                    = "${var.consul_tag}"
    consul_join                   = "${jsonencode(var.consul_join)}"
    consul_gossip_secret_key_name = "${jsonencode(var.consul_gossip_secret_key_name)}"

    service_name                = "${var.service_name}"
    service_type                = "${var.service_type}"
    service_external_port       = "${var.service_external_port}"
    service_port                = "${var.service_port}"
    service_cluster_ip          = "${jsonencode(var.service_cluster_ip)}"
    service_annotations         = "${jsonencode(var.service_annotations)}"
    load_balancer_ip            = "${jsonencode(var.service_load_balancer_ip)}"
    load_balancer_source_ranges = "${jsonencode(var.load_balancer_source_ranges)}"

    ingress_enabled     = "${var.ingress_enabled}"
    ingress_labels      = "${jsonencode(var.ingress_labels)}"
    ingress_hosts       = "${jsonencode(var.ingress_hosts)}"
    ingress_annotations = "${jsonencode(var.ingress_annotations)}"
    ingress_tls         = "${jsonencode(var.ingress_tls)}"

    cpu_request    = "${var.cpu_request}"
    memory_request = "${var.memory_request}"
    cpu_limit      = "${var.cpu_limit}"
    memory_limit   = "${var.memory_limit}"

    affinity        = "${jsonencode(var.affinity)}"
    annotations     = "${jsonencode(var.annotations)}"
    labels          = "${jsonencode(var.labels)}"
    pod_annotations = "${jsonencode(var.pod_annotations)}"
    lifecycle       = "${jsonencode(var.lifecycle)}"

    vault_dev              = "${var.vault_dev}"
    vault_secret_volumes   = "${jsonencode(var.vault_secret_volumes)}"
    vault_env              = "${jsonencode(var.vault_env)}"
    vault_extra_containers = "${jsonencode(var.vault_extra_containers)}"
    vault_extra_volumes    = "${jsonencode(var.vault_extra_volumes)}"
    vault_log_level        = "${var.vault_log_level}"
    vault_config           = "${jsonencode(merge(local.base_vault_config, var.vault_config))}"
  }
}