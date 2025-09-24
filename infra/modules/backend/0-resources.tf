# Azure Backend Module Resources - equivalent to AWS backend resources
# Handles environment configuration and template generation for all backend services

locals {
  split_instance_name             = split("-", var.instance_name)
  instance_name_capitalized_parts = [for part in local.split_instance_name : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_instance_name       = join("", local.instance_name_capitalized_parts)

  split_frontend_storage_name             = split("-", var.frontend_dashboard.app_bucket_name)
  frontend_storage_name_capitalized_parts = [for part in local.split_frontend_storage_name : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_frontend_storage_name       = join("", local.frontend_storage_name_capitalized_parts)
}

# Environment configuration templates for all backend services
locals {
  # Backend API environment configuration
  backend_api_env = templatefile("${path.module}/templates/env/backend.env.tpl", {
    env  = var.backend_api.env_flag
    port = var.backend_api.port

    # Database configuration (PostgreSQL)
    db_host     = var.rds_db.host
    db_port     = var.rds_db.port
    db_name     = var.rds_db.name
    db_username = var.rds_db.username
    db_password = var.rds_db.password

    # JWT configuration
    jwt_secret         = var.backend_api.jwt_secret
    jwt_refresh_secret = var.backend_api.jwt_refresh_secret

    # Third-party integrations
    agora_app_id   = var.agora.app_id
    agora_app_cert = var.agora.app_cert

    connecty_cube_app_id      = var.connecty_cube.app_id
    connecty_cube_auth_key    = var.connecty_cube.auth_key
    connecty_cube_auth_secret = var.connecty_cube.auth_secret

    # MQ service configuration (ActiveMQ runs on localhost)
    mqtt_service_url     = "http://127.0.0.1:${var.mqtt_service.port}/api"
    mqtt_service_api_key = var.mq_service_api_key

    # Azure Storage configuration (equivalent to AWS S3)
    aws_s3_access_key_id     = var.notification_config.azure_client_id
    aws_s3_secret_access_key = var.notification_config.azure_client_secret
    aws_s3_region            = var.notification_config.aws_region

    aws_app_bucket_name       = var.frontend_dashboard.app_bucket_name
    aws_thumbnail_bucket_name = var.frontend_dashboard.thumbnail_bucket_name

    # Notification configuration (Azure Communication Services + Service Bus)
    aws_sns_access_key_id     = var.notification_config.aws_sns_access_key_id
    aws_sns_secret_access_key = var.notification_config.aws_sns_secret_access_key
    aws_sns_region            = var.notification_config.aws_region
    aws_sns_sender            = var.backend_api.notification_sender

    aws_ses_access_key_id     = var.notification_config.aws_ses_access_key_id
    aws_ses_secret_access_key = var.notification_config.aws_ses_secret_access_key
    aws_ses_region            = var.notification_config.aws_region
    aws_ses_email             = var.backend_api.notification_email_sender

    super_admin = var.backend_api.super_admin

    firebase_account_key = var.backend_api.firebase_account_key

    # Event scheduler configuration
    event_scheduler_service_host = var.event_scheduler.host
    event_scheduler_service_port = var.event_scheduler.port

    compliance_notif_service_host = "127.0.0.1"
    compliance_notif_service_port = "3001"

    # Authentication keys
    server_to_server_auth_key       = var.inter_server_auth_key
    data_processing_server_auth_key = var.data_processing.api_key
    service_auth_key                = var.backend_api.service_api_key

    # Data processing service
    data_processing_server_base_url = "https://${var.data_processing.endpoint}:${var.data_processing.port}"

    # Frontend web app URL
    web_app_url = var.frontend_dashboard.endpoint
  })

  # Dashboard environment configuration
  dashboard_env = templatefile("${path.module}/templates/env/dashboard.env.tpl", {
    backend_api_endpoint     = "https://${var.backend_api.endpoint}:${var.backend_api.proxy_port}"
    data_processing_endpoint = "https://${var.data_processing.endpoint}:${var.data_processing.port}"
    local_storage_token      = var.frontend_dashboard.local_storage_token
  })

  # MQTT service environment configuration
  mqtt_service_env = templatefile("${path.module}/templates/env/mqtt-service.env.tpl", {
    is_prod        = var.mqtt_service.is_prod
    ssl_used       = var.mq.ssl_used
    mq_host        = var.mq.endpoint
    mq_port        = var.mq.port
    mq_username    = var.mq.username
    mq_password    = var.mq.password
    stomp_port     = var.mq.stomp_port
    nodejs_api_key = var.mq_service_api_key
    nodejs_api_url = "http://127.0.0.1:${var.backend_api.port}/api/"
  })

  # STOMP service environment configuration
  stomp_service_env = templatefile("${path.module}/templates/env/stomp-service.env.tpl", {
    ssl_used                    = var.mq.ssl_used
    mq_host                     = var.mq.endpoint
    mq_port                     = var.mq.port
    stomp_port                  = var.mq.stomp_port
    mq_username                 = var.mq.username
    mq_password                 = var.mq.password
    stomp_subscribe_destination = "/queue/${var.mq.gw_report_queue_name}"
    gateway_ping_url            = "https://${var.stomp_service.gateway_ping_endpoint}/"
    gateway_ping_source         = var.stomp_service.gateway_ping_source
    gateway_ping_api_key        = var.stomp_service.gateway_ping_api_key
    nodejs_api_key              = var.mq_service_api_key
    nodejs_api_url              = "http://127.0.0.1:${var.backend_api.port}/api/"
  })

  # Database initialization SQL
  init_db_sql = templatefile("${path.module}/templates/setup/init_db.sql.tpl", {
    db_user = var.rds_db.username

    dialog_env_key              = var.dialog_env_key
    firebase_project_id         = var.firebase.project_id
    firebase_storage_bucket     = var.firebase.storage_bucket
    firebase_app_measurement_id = var.firebase.app_measurement_id
    firebase_api_key            = var.firebase.api_key
    firebase_message_sender_id  = var.firebase.message_sender_id
    firebase_auth_domain        = var.firebase.auth_domain
    firebase_app_id             = var.firebase.app_id

    aus_ios_app_version     = var.mobile_app_versions.aus_ios
    sgp_ios_app_version     = var.mobile_app_versions.sgp_ios
    usa_ios_app_version     = var.mobile_app_versions.usa_ios
    aus_android_app_version = var.mobile_app_versions.aus_android
    sgp_android_app_version = var.mobile_app_versions.sgp_android
    usa_android_app_version = var.mobile_app_versions.usa_android
  })

  # Azure Storage configuration for initialization scripts (equivalent to AWS S3)
  storage_init_script_file_name = "init.sh"
  storage_init_script_key       = "${var.instance_name}/init-scripts/${local.storage_init_script_file_name}"

  storage_db_init_script_file_name = "db-init.sql"
  storage_db_init_script_key       = "${var.instance_name}/init-scripts/${local.storage_db_init_script_file_name}"

  # Main initialization script
  init_script = templatefile("${path.module}/templates/setup/init.sh.tpl", {
    artifact_folder      = var.artifact_folder
    authorization_key    = var.authorization_key
    backend_api_env      = local.backend_api_env
    frontend_bucket_name = var.frontend_dashboard.app_bucket_name
    dashboard_env        = local.dashboard_env
    mqtt_service_env     = local.mqtt_service_env
    stomp_service_env    = local.stomp_service_env

    mqtt_service_port  = var.mqtt_service.port
    stomp_service_port = var.stomp_service.port

    # Database configuration
    db_host     = var.rds_db.host
    db_port     = var.rds_db.port
    db_name     = var.rds_db.name
    db_username = var.rds_db.username
    db_password = var.rds_db.password

    app_bucket_name = var.frontend_dashboard.app_bucket_name

    # Storage configuration
    storage_account_name             = var.storage_account_name
    storage_db_init_script_file_name = local.storage_db_init_script_file_name
    storage_db_init_script_key       = local.storage_db_init_script_key
  })

  # Download and execute initialization script
  download_exec_init_script = templatefile("${path.module}/templates/setup/download_exec_init.sh.tpl", {
    storage_account_name          = var.storage_account_name
    storage_init_script_file_name = local.storage_init_script_file_name
    storage_init_script_key       = local.storage_init_script_key
  })
}

# Azure Storage Blob for initialization script (equivalent to AWS S3 object)
resource "azurerm_storage_blob" "init_script_blob" {
  name                   = local.storage_init_script_key
  storage_account_name   = var.storage_account_name
  storage_container_name = "configuration"
  type                   = "Block"
  source_content         = local.init_script
}

# Azure Storage Blob for database initialization script
resource "azurerm_storage_blob" "init_db_script_blob" {
  name                   = local.storage_db_init_script_key
  storage_account_name   = var.storage_account_name
  storage_container_name = "configuration"
  type                   = "Block"
  source_content         = local.init_db_sql
}
