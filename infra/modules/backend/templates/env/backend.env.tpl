APP_ENV=cloud
ENV=${env}
PORT=${port}
HOST=0.0.0.0

DB_HOST=${db_host}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
DB_PORT=${db_port}
DB_SYNC=true
DB_LOG=false

JWT_SECRET=${jwt_secret}
REFRESH_JWT_SECRET=${jwt_refresh_secret}

AGORA_APP_ID=${agora_app_id}
AGORA_APP_CERTIFICATE=${agora_app_cert}

CONNECTY_CUBE_APP_ID=${connecty_cube_app_id}
CONNECTY_CUBE_AUTHORIZATION_KEY=${connecty_cube_auth_key}
CONNECTY_CUBE_AUTHORIZATION_SECRET=${connecty_cube_auth_secret}

MQTT_SERVICE_URL=${mqtt_service_url}
MQTT_SERVICE_API_KEY=${mqtt_service_api_key}

AWS_S3_ACCESS_KEY_ID=${aws_s3_access_key_id}
AWS_S3_SECRET_ACCESS_KEY=${aws_s3_secret_access_key}
AWS_S3_REGION=${aws_s3_region}

AWS_PUBLIC_BUCKET_NAME=${aws_app_bucket_name}
AWS_PUBLIC_THUMBNAIL_BUCKET=${aws_thumbnail_bucket_name}

AWS_SNS_ACCESS_KEY_ID=${aws_sns_access_key_id}
AWS_SNS_SECRET_ACCESS_KEY=${aws_sns_secret_access_key}
AWS_SNS_REGION=${aws_sns_region}
AWS_SNS_SENDER=${aws_sns_sender}

AWS_SES_ACCESS_KEY_ID=${aws_ses_access_key_id}
AWS_SES_SECRET_ACCESS_KEY=${aws_ses_secret_access_key}
AWS_SES_REGION=${aws_ses_region}
EMAIL_FROM=${aws_ses_email}

FIREBASE_ACCOUNT_KEY=${firebase_account_key}

EVENT_SCHEDULER_SERVICE_HOST=${event_scheduler_service_host}
EVENT_SCHEDULER_SERVICE_PORT=${event_scheduler_service_port}

COMPLIANCE_NOTIFICATION_SERVICE_HOST=${compliance_notif_service_host}
COMPLIANCE_NOTIFICATION_SERVICE_PORT=${compliance_notif_service_port}

SERVER_TO_SERVER_AUTH_KEY=${server_to_server_auth_key}
DATA_PROCESSING_SERVER_AUTH_KEY=${data_processing_server_auth_key}
SERVICE_AUTH_KEY=${service_auth_key}
SUPER_ADMIN=${super_admin}

DATA_PROCESSING_SERVER_BASE_URL=${data_processing_server_base_url}

WEB_APP_URL="https://${web_app_url}"
 
DATA_PROCESSING_URL=${data_processing_server_base_url}
CONNECTYCUBE_APP_URL=https://api.connectycube.com
CHAT_ENABLED=true
AGORA_VIDEOCALL_ENABLED=true
FIREBASE_PUSH_NOTIFICATIONS_ENABLED=true
VERIFY_EMAIL_ENABLED=true
ADMIN_USERNAME=respiree_admin

SERVER_NAME=${env}
SWAGGER_USER=${env}
SWAGGER_PASSWORD=respiree@123