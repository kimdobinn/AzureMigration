# Azure Application Gateway Module - equivalent to AWS Application Load Balancer
# Provides Layer 7 load balancing, SSL termination, and health checking

# Public IP for Application Gateway - equivalent to AWS ALB public endpoint
resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pip"
    }
  )
}

# Application Gateway - equivalent to AWS Application Load Balancer
resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  # Backend pool - equivalent to AWS Target Group
  backend_address_pool {
    name = "backend-pool"
  }

  # Backend HTTP settings - equivalent to AWS Target Group health check
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = var.health_check_path
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 60

    probe_name = "health-probe"
  }

  # Health probe - equivalent to AWS Target Group health check
  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = var.health_check_path
    host                = "127.0.0.1"
    port                = var.backend_port
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Listener - equivalent to AWS ALB Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  # HTTPS Listener - equivalent to AWS ALB HTTPS Listener
  dynamic "http_listener" {
    for_each = var.ssl_certificate_id != null ? [1] : []
    content {
      name                           = "https-listener"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "frontend-port-443"
      protocol                       = "Https"
      ssl_certificate_name           = "ssl-cert"
    }
  }

  # SSL Certificate - equivalent to AWS ACM certificate
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_id != null ? [1] : []
    content {
      name     = "ssl-cert"
      key_vault_secret_id = var.ssl_certificate_id
    }
  }

  # Request routing rule for HTTP - equivalent to AWS ALB routing rules
  request_routing_rule {
    name                       = "http-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  # Request routing rule for HTTPS - equivalent to AWS ALB HTTPS routing
  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_id != null ? [1] : []
    content {
      name                       = "https-routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "https-listener"
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http-settings"
      priority                   = 101
    }
  }

  tags = merge(
    var.tags,
    {
      Name         = var.name
      Service      = "ApplicationGateway"
      MigratedFrom = "AWS-ApplicationLoadBalancer"
    }
  )
}

# Backend address pool association - equivalent to AWS Target Group attachment
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "this" {
  count                   = length(var.backend_vm_network_interface_ids)
  network_interface_id    = var.backend_vm_network_interface_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = tolist(azurerm_application_gateway.this.backend_address_pool)[0].id
}