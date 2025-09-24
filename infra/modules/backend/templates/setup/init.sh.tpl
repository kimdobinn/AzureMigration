echo "===== Installing necessary COTS ====="

echo "===== Installing GIT ====="
apt-get update
apt-get install -y git

echo "===== Installing Java ====="
apt-get install -y openjdk-11-jdk

echo "===== Installing Docker ====="
apt-get install -y docker.io

echo "===== Installing Docker-Compose ====="
curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "===== Installing NodeJS / NPM ====="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

echo "===== Installing Python ====="
apt-get install -y python3 python3-pip

echo "===== Installing gunicorn ====="
pip3 install gunicorn

echo "===== Installing PM2 ====="
npm install pm2@latest -g

echo -e "\n\n\n===== Installing build tools for building node-gyp ====="
echo "===== Installing GCC / GCC+ ====="
apt-get install -y gcc g++

echo -e "\n\n\n===== Installing build tools for building python modules ====="
echo "===== Installing python3-dev ====="
apt-get install -y python3-dev

echo -e "\n\n\n===== Installing postgresql client to initialize database ====="
apt-get install -y postgresql-client

echo -e "\n\n\n===== Installing Azure CLI ====="
curl -sL https://aka.ms/InstallAzureCLIMSI | bash

echo -e "\n\n\n===== Starting Docker service ====="
systemctl start docker
systemctl enable docker

echo -e "\n\n\n===== Installing ActiveMQ ====="
cd /opt
wget https://archive.apache.org/dist/activemq/5.18.3/apache-activemq-5.18.3-bin.tar.gz
tar -xzf apache-activemq-5.18.3-bin.tar.gz
mv apache-activemq-5.18.3 activemq
chown -R root:root activemq

echo "===== Configuring ActiveMQ ====="
cat > /opt/activemq/conf/activemq.xml << 'EOF'
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
  http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">
    <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
            <value>file:$${activemq.conf}/credentials.properties</value>
        </property>
    </bean>
    <broker xmlns="http://activemq.apache.org/schema/core" brokerName="localhost" dataDirectory="$${activemq.data}">
        <destinationPolicy>
            <policyMap>
                <policyEntries>
                    <policyEntry topic=">" >
                        <pendingMessageLimitStrategy>
                            <constantPendingMessageLimitStrategy limit="1000"/>
                        </pendingMessageLimitStrategy>
                    </policyEntry>
                </policyEntries>
            </policyMap>
        </destinationPolicy>
        <managementContext>
            <managementContext createConnector="false"/>
        </managementContext>
        <persistenceAdapter>
            <kahaDB directory="$${activemq.data}/kahadb"/>
        </persistenceAdapter>
        <systemUsage>
            <systemUsage>
                <memoryUsage>
                    <memoryUsage percentOfJvmHeap="70" />
                </memoryUsage>
                <storeUsage>
                    <storeUsage limit="100 gb"/>
                </storeUsage>
                <tempUsage>
                    <tempUsage limit="50 gb"/>
                </tempUsage>
            </systemUsage>
        </systemUsage>
        <transportConnectors>
            <transportConnector name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="amqp" uri="amqp://0.0.0.0:5672?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="stomp" uri="stomp://0.0.0.0:61613?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="mqtt" uri="mqtt://0.0.0.0:1883?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="ws" uri="ws://0.0.0.0:61614?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
        </transportConnectors>
        <shutdownHooks>
            <bean xmlns="http://www.springframework.org/schema/beans" class="org.apache.activemq.hooks.SpringContextHook" />
        </shutdownHooks>
    </broker>
    <import resource="jetty.xml"/>
</beans>
EOF

echo "===== Creating ActiveMQ systemd service ====="
cat > /etc/systemd/system/activemq.service << 'EOF'
[Unit]
Description=Apache ActiveMQ
After=network.target

[Service]
Type=forking
User=root
Group=root
ExecStart=/opt/activemq/bin/activemq start
ExecStop=/opt/activemq/bin/activemq stop
ExecReload=/opt/activemq/bin/activemq restart
PIDFile=/opt/activemq/data/activemq.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "===== Starting ActiveMQ service ====="
systemctl daemon-reload
systemctl enable activemq
systemctl start activemq

echo -e "\n\n\n===== Setting up base system ====="
# Declare service username variable
export SVC_USER=appsvc

echo "===== Creating service user $SVC_USER ====="
adduser --disabled-password --gecos "" $SVC_USER

# Declare application directory variables
export APP_DIR=/home/$SVC_USER

echo -e "\n\n\n===== Setting up ubuntu user ssh authorization key ====="
echo '${authorization_key}' >> /home/ubuntu/.ssh/authorized_keys

echo -e "\n\n\n===== Setting up backend-api ====="
# Setup env variables and directories
export ENV_DIR=$APP_DIR/env
export BACKEND_ENV_DIR=$ENV_DIR/respiree-backend

echo "===== Creating env directory ====="
mkdir -p $BACKEND_ENV_DIR

echo "===== Creating backend-api env file ====="
echo '${backend_api_env}' > $BACKEND_ENV_DIR/.env

# Export backend-api application variables / directories
export BACKEND_API_FILE_NAME=backend-api.zip
export BACKEND_API_DIR=$APP_DIR/backend-api
export BACKEND_API_TMP_DIR=$BACKEND_API_DIR-tmp
export DOWNLOADED_BACKEND_API_FILE_PATH=$BACKEND_API_TMP_DIR/$BACKEND_API_FILE_NAME

echo "===== Creating backend-api directories ====="
mkdir -p $BACKEND_API_DIR
mkdir -p $BACKEND_API_TMP_DIR

echo "===== Downloading backend-api application from Azure Storage ====="
az storage blob download --account-name ${storage_account_name} --container-name ${artifact_folder} --name $BACKEND_API_FILE_NAME --file $DOWNLOADED_BACKEND_API_FILE_PATH --auth-mode login
export BACKEND_API_EXTRACTED_DIR=$BACKEND_API_TMP_DIR/$(unzip -l $DOWNLOADED_BACKEND_API_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_BACKEND_API_FILE_PATH -d $BACKEND_API_TMP_DIR

echo "===== Changing directory to $BACKEND_API_EXTRACTED_DIR to build application ====="
cd $BACKEND_API_EXTRACTED_DIR

echo "===== Installing backend-api dependencies ====="
npm install --legacy-peer-deps
npm run build

echo "===== Moving built files from tmp directory to actual directory ====="
mv node_modules $BACKEND_API_DIR
mv assets $BACKEND_API_DIR
mv dist $BACKEND_API_DIR

echo "===== Giving ownership of $BACKEND_API_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $BACKEND_API_DIR

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Install pm2 log-rotate and save auto start configuration ====="
sudo -u appsvc bash <<EOF
pm2 install pm2-logrotate
pm2 save
EOF

echo "===== Run backend-api and save configuration ====="
sudo -u appsvc bash <<EOF
cd $BACKEND_API_DIR
pm2 start dist/src/main.js --name backend-api
pm2 save
EOF

echo "===== Deleting $BACKEND_API_TMP_DIR directory ====="
rm -rf $BACKEND_API_TMP_DIR

echo -e "\n\n\n===== Setting up mqtt-service ====="
# Export mqtt-service application variables / directories
export MQTT_SERVICE_FILE_NAME=mqtt-service.zip
export MQTT_SERVICE_DIR=$APP_DIR/mqtt-service
export MQTT_SERVICE_TMP_DIR=$MQTT_SERVICE_DIR-tmp
export DOWNLOADED_MQTT_SERVICE_FILE_PATH=$MQTT_SERVICE_TMP_DIR/$MQTT_SERVICE_FILE_NAME

echo "===== Creating mqtt-service-tmp directory ====="
mkdir -p $MQTT_SERVICE_TMP_DIR

echo "===== Downloading mqtt-service application from Azure Storage ====="
az storage blob download --account-name ${storage_account_name} --container-name artifacts --name $MQTT_SERVICE_FILE_NAME --file $DOWNLOADED_MQTT_SERVICE_FILE_PATH --auth-mode login
export MQTT_SERVICE_EXTRACTED_DIR=$MQTT_SERVICE_TMP_DIR/$(unzip -l $DOWNLOADED_MQTT_SERVICE_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_MQTT_SERVICE_FILE_PATH -d $MQTT_SERVICE_TMP_DIR
mv $MQTT_SERVICE_EXTRACTED_DIR $MQTT_SERVICE_DIR

echo '${mqtt_service_env}' > $MQTT_SERVICE_DIR/.env

echo "===== Changing directory to $MQTT_SERVICE_DIR to install dependencies ====="
cd $MQTT_SERVICE_DIR
pip3 install -r requirements.txt

echo "===== Giving ownership of $MQTT_SERVICE_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $MQTT_SERVICE_DIR

echo "===== Run mqtt-service and save configuration ====="
sudo -u appsvc bash <<EOF
cd $MQTT_SERVICE_DIR
pip3 install -r requirements.txt
pm2 start "gunicorn -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:${mqtt_service_port} app.main:app" --name mqtt-service
pm2 save
EOF

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $MQTT_SERVICE_TMP_DIR directory ====="
rm -rf $MQTT_SERVICE_TMP_DIR

echo -e "\n\n\n===== Setting up stomp-service ====="
# Export stomp-service application variables / directories
export STOMP_SERVICE_FILE_NAME=stomp-service.zip
export STOMP_SERVICE_DIR=$APP_DIR/stomp-service
export STOMP_SERVICE_TMP_DIR=$STOMP_SERVICE_DIR-tmp
export DOWNLOADED_STOMP_SERVICE_FILE_PATH=$STOMP_SERVICE_TMP_DIR/$STOMP_SERVICE_FILE_NAME

echo "===== Creating stomp-service-tmp directory ====="
mkdir -p $STOMP_SERVICE_TMP_DIR

echo "===== Downloading stomp-service application from Azure Storage ====="
az storage blob download --account-name ${storage_account_name} --container-name artifacts --name $STOMP_SERVICE_FILE_NAME --file $DOWNLOADED_STOMP_SERVICE_FILE_PATH --auth-mode login
export STOMP_SERVICE_EXTRACTED_DIR=$STOMP_SERVICE_TMP_DIR/$(unzip -l $DOWNLOADED_STOMP_SERVICE_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_STOMP_SERVICE_FILE_PATH -d $STOMP_SERVICE_TMP_DIR
mv $STOMP_SERVICE_EXTRACTED_DIR $STOMP_SERVICE_DIR

echo '${stomp_service_env}' > $STOMP_SERVICE_DIR/.env

echo "===== Changing directory to $STOMP_SERVICE_DIR to install dependencies ====="
cd $STOMP_SERVICE_DIR
pip3 install -r requirements.txt

echo "===== Giving ownership of $STOMP_SERVICE_DIR directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $STOMP_SERVICE_DIR

echo "===== Run stomp-service and save configuration ====="
sudo -u appsvc bash <<EOF
cd $STOMP_SERVICE_DIR
pip3 install -r requirements.txt
pm2 start "gunicorn -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:${stomp_service_port} app.main:app" --name stomp-service
pm2 save
EOF

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $STOMP_SERVICE_TMP_DIR directory ====="
rm -rf $STOMP_SERVICE_TMP_DIR

echo -e "\n\n\n===== Finalizing setup ====="
echo "===== Giving ownership of env directory to $SVC_USER ====="
chown -R $SVC_USER:$SVC_USER $ENV_DIR

echo "===== Configure pm2 to run on server startup using $SVC_USER ====="
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $SVC_USER --hp $APP_DIR

echo -e "\n\n\n===== Deploy frontend dashboard ====="
# Export dashboard application directory
export DASHBOARD_FILE_NAME=dashboard.zip
export DASHBOARD_TMP_DIR=$APP_DIR/dashboard-tmp
export DOWNLOADED_DASHBOARD_FILE_PATH=$DASHBOARD_TMP_DIR/$DASHBOARD_FILE_NAME

echo "===== Creating dashboard directory ====="
mkdir -p $DASHBOARD_TMP_DIR

echo "===== Downloading dashboard application from Azure Storage ====="
az storage blob download --account-name ${storage_account_name} --container-name ${artifact_folder} --name $DASHBOARD_FILE_NAME --file $DOWNLOADED_DASHBOARD_FILE_PATH --auth-mode login
export DASHBOARD_EXTRACTED_DIR=$DASHBOARD_TMP_DIR/$(unzip -l $DOWNLOADED_DASHBOARD_FILE_PATH | grep /$ | awk 'NR==1 {print $4}')
unzip $DOWNLOADED_DASHBOARD_FILE_PATH -d $DASHBOARD_TMP_DIR

echo "===== Changing directory to $DASHBOARD_EXTRACTED_DIR to build application ====="
cd $DASHBOARD_EXTRACTED_DIR

echo "===== Creating dashboard env file ====="
echo '${dashboard_env}' >> .env

echo "===== Installing dashboard dependencies ====="
rm -rf node_modules package-lock.json
npm cache clean --force
npm install 
npm install --legacy-peer-deps
npm install linkify-html linkifyjs --save
npm install --save-dev @rollup/plugin-node-resolve

echo "===== Building dashboard ====="
npm run build

echo "===== Upload dashboard to frontend Storage Account ====="
az storage blob upload-batch --account-name ${frontend_bucket_name} --destination '$web' --source build --auth-mode login

echo "===== Returning back to root home directory ====="
cd ~

echo "===== Deleting $DASHBOARD_TMP_DIR directory ====="
rm -rf $DASHBOARD_TMP_DIR

echo "===== Copy static files from Artifact Storage to app Storage ====="
az storage blob copy start-batch --account-name ${app_bucket_name} --destination-container static_files --source-account-name ${storage_account_name} --source-container static_files --auth-mode login

echo -e "\n\n\n===== Initializing database ====="
export DB_INIT_FILE_NAME=${storage_db_init_script_file_name}

echo "===== Downloading $DB_INIT_FILE_NAME from Azure Storage ====="
az storage blob download --account-name ${storage_account_name} --container-name configuration --name ${storage_db_init_script_key} --file /tmp/$DB_INIT_FILE_NAME --auth-mode login

export PGHOST="${db_host}"
export PGPORT="${db_port}"
export PGUSER="${db_username}"
export PGPASSWORD="${db_password}"
export PGDATABASE="${db_name}"

echo "===== Executing DB init script ====="
psql -f /tmp/$DB_INIT_FILE_NAME

echo "===== Cleaning up DB initialization ====="
rm /tmp/$DB_INIT_FILE_NAME

echo "SETUP COMPLETE!"