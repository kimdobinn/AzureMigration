#!/bin/bash

echo "===== Azure Event-Scheduler VM Setup - Equivalent to AWS EC2 Setup ====="

echo "===== Installing necessary packages ====="

echo "===== Installing NodeJS / NPM ====="
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

echo "===== Installing PM2 ====="
sudo npm install pm2@latest -g

echo "===== Installing Azure CLI for blob storage access ====="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
sudo yum install -y azure-cli

echo -e "\n\n\n===== Setting up base system ====="
# Declare service username variable
export SVC_USER=appsvc

echo "===== Creating service user $SVC_USER ====="
sudo adduser $SVC_USER

# Declare application directory variables
export APP_DIR=/home/$SVC_USER

echo -e "\n\n\n===== Setting up SSH key for azureuser ====="
echo '${ssh_public_key}' >> /home/azureuser/.ssh/authorized_keys

echo "\n\n\n===== Setting up event-scheduler ====="
# Setup env variables and directories
export ENV_DIR=$APP_DIR/env
export BACKEND_ENV_DIR=$ENV_DIR/respiree-backend

echo "===== Creating env directory ====="
sudo mkdir -p $BACKEND_ENV_DIR

echo "===== Creating event-scheduler env file ====="
echo '${event_scheduler_env}' | sudo tee $BACKEND_ENV_DIR/event_scheduler.env

# Export event-scheduler application variables / directories
export EVENT_SCHEDULER_FILE_NAME=event-scheduler.zip
export EVENT_SCHEDULER_DIR=$APP_DIR/event-scheduler
export EVENT_SCHEDULER_TMP_DIR=$EVENT_SCHEDULER_DIR-tmp
export DOWNLOADED_EVENT_SCHEDULER_FILE_PATH=$EVENT_SCHEDULER_TMP_DIR/$EVENT_SCHEDULER_FILE_NAME

echo "===== Creating event-scheduler directories ====="
sudo mkdir -p $EVENT_SCHEDULER_DIR
sudo mkdir -p $EVENT_SCHEDULER_TMP_DIR

echo "===== Downloading event-scheduler application from Azure Blob Storage ====="
# Note: You'll need to upload event-scheduler.zip to your storage account first
# Using Azure CLI to download from blob storage (equivalent to AWS S3 cp)
az storage blob download \
    --account-name ${storage_account_name} \
    --account-key ${storage_account_key} \
    --container-name artifacts \
    --name $EVENT_SCHEDULER_FILE_NAME \
    --file $DOWNLOADED_EVENT_SCHEDULER_FILE_PATH

export EVENT_SCHEDULER_EXTRACTED_DIR=$EVENT_SCHEDULER_TMP_DIR/$(unzip -l $DOWNLOADED_EVENT_SCHEDULER_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
sudo unzip $DOWNLOADED_EVENT_SCHEDULER_FILE_PATH -d $EVENT_SCHEDULER_TMP_DIR

echo "===== Changing directory to $EVENT_SCHEDULER_EXTRACTED_DIR to build application ====="
cd $EVENT_SCHEDULER_EXTRACTED_DIR

echo "===== Installing event-scheduler dependencies ====="
sudo npm install --legacy-peer-deps

echo "===== Building event-scheduler ====="
sudo npm run build

echo "===== Moving built files from tmp directory to actual directory ====="
sudo mv node_modules $EVENT_SCHEDULER_DIR
sudo mv dist $EVENT_SCHEDULER_DIR

echo "===== Downloading Azure Cosmos DB SSL certificate (equivalent to AWS DocumentDB PEM) ====="
# Azure Cosmos DB uses different SSL certificates than AWS DocumentDB
sudo wget https://cacerts.digicert.com/BaltimoreCyberTrustRoot.crt.pem -P $EVENT_SCHEDULER_DIR

echo "===== Giving ownership of $EVENT_SCHEDULER_DIR directory to $SVC_USER ====="
sudo chown -R $SVC_USER:$SVC_USER $EVENT_SCHEDULER_DIR

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Install pm2 log-rotate and save auto start configuration ====="
sudo -u appsvc bash <<EOF
pm2 install pm2-logrotate
pm2 save
EOF

echo "===== Run event-scheduler and save configuration ====="
sudo -u appsvc bash <<EOF
cd $EVENT_SCHEDULER_DIR
pm2 start dist/main.js --name event-scheduler
pm2 save
EOF

echo "===== Deleting $EVENT_SCHEDULER_TMP_DIR directory ====="
sudo rm -rf $EVENT_SCHEDULER_TMP_DIR

echo "\n\n\n===== Finalizing setup ====="
echo "===== Giving ownership of env directory to $SVC_USER ====="
sudo chown -R $SVC_USER:$SVC_USER $ENV_DIR

echo "===== Configure pm2 to run on server startup using $SVC_USER ====="
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $SVC_USER --hp $APP_DIR

echo "AZURE EVENT-SCHEDULER SETUP COMPLETE!"