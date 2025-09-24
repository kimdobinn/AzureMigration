export INIT_SCRIPT_PATH=/tmp/${storage_init_script_file_name}
az storage blob download --account-name ${storage_account_name} --container-name configuration --name ${storage_init_script_key} --file $INIT_SCRIPT_PATH --auth-mode login
chmod +x $INIT_SCRIPT_PATH
./$INIT_SCRIPT_PATH
rm -rf $INIT_SCRIPT_PATH