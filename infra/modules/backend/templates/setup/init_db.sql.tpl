-- Azure PostgreSQL Database Initialization Script
-- Equivalent to AWS RDS/DocumentDB initialization
-- This script initializes the database with required tables, data, and configurations

START TRANSACTION;
SELECT * FROM current_schema();
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT version();

-- Create basic application configuration tables
CREATE TABLE IF NOT EXISTS "app_config" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "key" character varying(255) NOT NULL,
    "value" text,
    "description" text,
    "created_at" TIMESTAMP NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMP DEFAULT now(),
    CONSTRAINT "PK_app_config" PRIMARY KEY ("id"),
    CONSTRAINT "UQ_app_config_key" UNIQUE ("key")
);

-- Insert Firebase configuration
INSERT INTO "app_config" ("key", "value", "description") VALUES
('firebase_project_id', '${firebase_project_id}', 'Firebase Project ID'),
('firebase_storage_bucket', '${firebase_storage_bucket}', 'Firebase Storage Bucket'),
('firebase_app_measurement_id', '${firebase_app_measurement_id}', 'Firebase App Measurement ID'),
('firebase_api_key', '${firebase_api_key}', 'Firebase API Key'),
('firebase_message_sender_id', '${firebase_message_sender_id}', 'Firebase Message Sender ID'),
('firebase_auth_domain', '${firebase_auth_domain}', 'Firebase Auth Domain'),
('firebase_app_id', '${firebase_app_id}', 'Firebase App ID')
ON CONFLICT ("key") DO UPDATE SET 
    "value" = EXCLUDED."value",
    "updated_at" = now();

-- Insert Dialog environment key
INSERT INTO "app_config" ("key", "value", "description") VALUES
('dialog_env_key', '${dialog_env_key}', 'Dialog Environment Key')
ON CONFLICT ("key") DO UPDATE SET 
    "value" = EXCLUDED."value",
    "updated_at" = now();

-- Create mobile app version configuration table
CREATE TABLE IF NOT EXISTS "app_version" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "platform" character varying(50) NOT NULL,
    "region" character varying(10) NOT NULL,
    "version" character varying(20) NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" TIMESTAMP NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMP DEFAULT now(),
    CONSTRAINT "PK_app_version" PRIMARY KEY ("id"),
    CONSTRAINT "UQ_app_version_platform_region" UNIQUE ("platform", "region")
);

-- Insert mobile app versions
INSERT INTO "app_version" ("platform", "region", "version") VALUES
('ios', 'aus', '${aus_ios_app_version}'),
('ios', 'sgp', '${sgp_ios_app_version}'),
('ios', 'usa', '${usa_ios_app_version}'),
('android', 'aus', '${aus_android_app_version}'),
('android', 'sgp', '${sgp_android_app_version}'),
('android', 'usa', '${usa_android_app_version}')
ON CONFLICT ("platform", "region") DO UPDATE SET 
    "version" = EXCLUDED."version",
    "updated_at" = now();

-- Create constants table for application constants
CREATE TABLE IF NOT EXISTS "constants" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "name" character varying(255) NOT NULL,
    "value" text NOT NULL,
    "type" character varying(50) NOT NULL DEFAULT 'string',
    "description" text,
    "created_at" TIMESTAMP NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMP DEFAULT now(),
    CONSTRAINT "PK_constants" PRIMARY KEY ("id"),
    CONSTRAINT "UQ_constants_name" UNIQUE ("name")
);

-- Insert basic constants
INSERT INTO "constants" ("name", "value", "type", "description") VALUES
('system_initialized', 'true', 'boolean', 'System initialization flag'),
('database_version', '1.0.0', 'string', 'Database schema version'),
('environment', 'azure', 'string', 'Deployment environment'),
('migration_source', 'aws', 'string', 'Source of migration')
ON CONFLICT ("name") DO UPDATE SET 
    "value" = EXCLUDED."value",
    "updated_at" = now();

-- Grant permissions to database user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${db_user}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${db_user}";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO "${db_user}";

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS "idx_app_config_key" ON "app_config" ("key");
CREATE INDEX IF NOT EXISTS "idx_app_version_platform_region" ON "app_version" ("platform", "region");
CREATE INDEX IF NOT EXISTS "idx_constants_name" ON "constants" ("name");

COMMIT;

-- Log successful initialization
SELECT 'Database initialization completed successfully' as status;