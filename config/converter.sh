
# Substitute environment variables in acmEmailSender.properties
envsubst < config/properties/acmEmailSender.properties > /root/.arkcase/acm/acm-config-server-repo/acmEmailSender_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/acmEmailSender_temp.properties /root/.arkcase/acm/acm-config-server-repo/acmEmailSender.properties

# Substitute environment variables in wopiPlugin.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/wopiPlugin.properties > /root/.arkcase/acm/acm-config-server-repo/wopiPlugin_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/wopiPlugin_temp.properties /root/.arkcase/acm/acm-config-server-repo/wopiPlugin.properties

# Substitute environment variables in datasource.properties
envsubst < /root/.arkcase/acm/acm-config-server-repo/datasource.properties > /root/.arkcase/acm/acm-config-server-repo/datasource_temp.properties
mv /root/.arkcase/acm/acm-config-server-repo/datasource_temp.properties /root/.arkcase/acm/acm-config-server-repo/datasource.properties
