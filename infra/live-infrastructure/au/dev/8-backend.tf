# Azure Backend Infrastructure - equivalent to AWS backend infrastructure
# Creates backend VM with Node.js API, ActiveMQ, MQTT/STOMP services, and Application Gateway

# Backend VM with all applications - equivalent to AWS backend EC2
module "backend_vm" {
  source = "../../../modules/backend"

  # Basic VM configuration
  instance_name       = local.backend_instance_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  instance_type       = var.backend_instance_type

  # Network configuration
  subnet_id           = module.vnet.private_subnet_ids[0]
  allowed_cidr_blocks = module.vnet.vnet_address_space

  # SSH configuration
  ssh_public_key = var.ssh_public_key

  # Storage configuration
  root_block_device = {
    caching     = "ReadWrite"
    volume_type = var.backend_os_disk_type
    volume_size = var.backend_os_disk_size
  }

  # Application artifacts
  artifact_folder      = local.artifact_folder
  storage_account_name = azurerm_storage_account.artifacts_storage.name
  storage_account_key  = azurerm_storage_account.artifacts_storage.primary_access_key

  # Database configuration - equivalent to AWS RDS
  rds_db = {
    host     = module.postgresql.postgresql_server_fqdn
    port     = "5432"
    name     = "postgres" # Default database name
    username = var.postgresql_flexible_server_admin_username
    password = var.postgresql_flexible_server_admin_password
  }

  # Message Queue configuration - ActiveMQ (same as AWS)
  mq = {
    ssl_used             = 0 # Not using SSL for local ActiveMQ
    username             = var.mq_username
    password             = var.mq_password
    endpoint             = "localhost" # ActiveMQ runs on same VM
    port                 = var.mq_port
    stomp_port           = var.mq_stomp_port
    gw_report_topic_name = var.mq_gw_report_topic_name
    gw_report_queue_name = var.mq_gw_report_queue_name
  }

  # Backend API configuration
  backend_api = {
    endpoint                  = module.backend_lb.endpoint # Application Gateway endpoint
    port                      = var.backend_port
    proxy_port                = var.backend_proxy_port
    env_flag                  = var.backend_env_flag
    jwt_secret                = var.backend_jwt_secret
    jwt_refresh_secret        = var.backend_jwt_refresh_secret
    service_api_key           = var.backend_service_api_key
    notification_sender       = var.backend_notification_sender
    notification_email_sender = var.backend_notification_email_sender
    super_admin               = var.backend_super_admin
    firebase_account_key      = var.backend_firebase_account_key
  }

  # Frontend dashboard configuration
  frontend_dashboard = {
    app_bucket_name       = azurerm_storage_account.app_storage.name
    thumbnail_bucket_name = azurerm_storage_account.thumbnail_storage.name
    endpoint              = module.frontend.cdn_endpoint_hostname
    local_storage_token   = var.frontend_local_storage_token
  }

  # External services
  data_processing = {
    endpoint = var.data_processing_endpoint
    port     = var.data_processing_port
    api_key  = var.data_processing_api_key
  }

  # Event scheduler configuration
  event_scheduler = {
    host = module.event_scheduler_vm.endpoint
    port = var.event_scheduler_port
  }

  # MQTT service configuration
  mqtt_service = {
    is_prod = var.mqtt_service_is_prod
    host    = "localhost" # Runs on same VM as backend
    port    = var.mq_service_port
  }

  # STOMP service configuration
  stomp_service = {
    host                  = "localhost" # Runs on same VM as backend
    port                  = var.stomp_service_port
    gateway_ping_endpoint = var.stomp_service_gateway_ping_endpoint
    gateway_ping_source   = "${local.backend_instance_name}-stomp-service"
    gateway_ping_api_key  = var.stomp_service_gateway_ping_api_key
  }

  mq_service_api_key = var.mq_service_api_key

  # Third-party integrations
  agora = {
    app_id   = var.agora_app_id
    app_cert = var.agora_app_cert
  }

  connecty_cube = {
    app_id      = var.connecty_cube_app_id
    auth_key    = var.connecty_cube_auth_key
    auth_secret = var.connecty_cube_auth_secret
  }

  firebase = {
    project_id         = var.firebase_project_id
    app_id             = var.firebase_app_id
    storage_bucket     = var.firebase_storage_bucket
    app_measurement_id = var.firebase_app_measurement_id
    api_key            = var.firebase_api_key
    message_sender_id  = var.firebase_message_sender_id
    auth_domain        = var.firebase_auth_domain
  }

  # Mobile app versions for database initialization
  mobile_app_versions = {
    aus_ios     = var.mobile_app_aus_ios_version
    sgp_ios     = var.mobile_app_sgp_ios_version
    usa_ios     = var.mobile_app_usa_ios_version
    aus_android = var.mobile_app_aus_android_version
    sgp_android = var.mobile_app_sgp_android_version
    usa_android = var.mobile_app_usa_android_version
  }

  # Authorization key for SSH access
  authorization_key = var.ssh_public_key

  dialog_env_key = var.dialog_env_key

  inter_server_auth_key = var.inter_server_auth_key

  # Notification configuration - pass from notification module
  notification_config = module.notification.notification_config

  tags = {
    Environment  = var.environment
    Service      = "Backend"
    MigratedFrom = "AWS-Backend-EC2"
  }
}

# Application Gateway (Load Balancer) - equivalent to AWS Application Load Balancer
module "backend_lb" {
  source = "../../../modules/common/application-gateway"

  # Basic configuration
  name                = "${local.resource_name_prefix}-app-gateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # Network configuration
  subnet_id = module.vnet.public_subnet_ids[0] # Application Gateway needs public subnet

  # Backend configuration
  backend_vm_network_interface_ids = [module.backend_vm.network_interface_id]
  backend_port                     = var.backend_port
  health_check_path                = "/api"

  # Application Gateway configuration
  sku_name = var.backend_lb_sku_name
  sku_tier = var.backend_lb_sku_tier
  capacity = var.backend_lb_capacity

  # SSL configuration (optional)
  ssl_certificate_id = var.backend_ssl_certificate_id

  tags = {
    Environment  = var.environment
    Service      = "ApplicationGateway"
    MigratedFrom = "AWS-ApplicationLoadBalancer"
  }
}

# Local variables for naming
locals {
  backend_instance_name = "${local.resource_name_prefix}-backend"
  artifact_folder       = "artifacts"
}
