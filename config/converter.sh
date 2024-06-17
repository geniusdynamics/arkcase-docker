
echo "Environment variables before substitution:"
env
# SUBSTITUTE ENVIRONMENT VARIABLES IN arkcase.yaml
envsubst < /root/.arkcase/acm/acm-config-server-repo/arkcase.yaml > /root/.arkcase/acm/acm-config-server-repo/arkcase_temp.yaml
mv /root/.arkcase/acm/acm-config-server-repo/arkcase_temp.yaml /root/.arkcase/acm/acm-config-server-repo/arkcase.yaml

# Substitute environment variables in acmEmailSender.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/acmEmailSender.properties > /root/.arkcase/acm/acm-config-server-repo/acmEmailSender_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/acmEmailSender_temp.properties /root/.arkcase/acm/acm-config-server-repo/acmEmailSender.properties

# Substitute environment variables in wopiPlugin.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/wopiPlugin.properties > /root/.arkcase/acm/acm-config-server-repo/wopiPlugin_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/wopiPlugin_temp.properties /root/.arkcase/acm/acm-config-server-repo/wopiPlugin.properties

# Substitute environment variables in datasource.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/datasource.properties > /root/.arkcase/acm/acm-config-server-repo/datasource_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/datasource_temp.properties /root/.arkcase/acm/acm-config-server-repo/datasource.properties
# Print environment variables after substitution

# Substitute activeMQ environment variables in arkcase-activemq.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/arkcase-activemq.properties > /root/.arkcase/acm/acm-config-server-repo/arkcase-activemq_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/arkcase-activemq_temp.properties /root/.arkcase/acm/acm-config-server-repo/arkcase-activemq.properties
