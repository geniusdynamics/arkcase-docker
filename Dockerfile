# Use an official Tomcat base image with Java 11
FROM tomcat:9.0.65-jdk11-openjdk

# Maintainer information
LABEL maintainer="kemboielvis@genius.ke"

# Set environment variables
ENV JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Duser.timezone=GMT \
  -Djavax.net.ssl.keyStorePassword=password \
  -Djavax.net.ssl.trustStorePassword=password \
  -Djavax.net.ssl.keyStore=/root/.arkcase/acm/private/arkcase.ks \
  -Djavax.net.ssl.trustStore=/root/.arkcase/acm/private/arkcase.ts \
  -Dspring.profiles.active=ldap \
  -Dacm.configurationserver.propertyfile=/root/.arkcase/acm/conf.yml \
  -Djava.security.egd=file:/dev/./urandom \
  -Djava.util.logging.config.file=/root/.arkcase/acm/log4j2.xml \
    -Dconfiguration.client.spring.path=/root/.arkcase/acm/acm-config-server-repo/spring/auditPatterns.properties \
  -Xms1024M -Xmx1024M"

ENV APP_NAME="arkcase"
ENV APP_URL="http://localhost"
ENV APP_DOMAIN="localhost"

#ENV CATALINA_OPTS="/usr/local/opt/tomcat-native/lib"
# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

# Clone the configuration repository
RUN git clone https://github.com/ArkCase/.arkcase /root/.arkcase

# Download Config Server JAR
RUN curl -L -o /usr/local/tomcat/config-server.jar https://github.com/ArkCase/acm-config-server/releases/download/2021.03/config-server-2021.03.jar

# Copy ArkCase WAR file and configurations
COPY config/arkcase-2021.03.01.war /usr/local/tomcat/webapps/arkcase.war
COPY config/arkcase.yaml /root/.arkcase/acm/acm-config-server-repo/arkcase.yaml
COPY config/properties/quartz.properties /root/.arkcase/acm/acm-config-server-repo/spring/quartz.properties
COPY config/properties/wopiPlugin.properties /root/.arkcase/acm/acm-config-server-repo/wopiPlugin.properties
#COPY config/properties/datasource.properties /root/.arkcase/acm/acm-config-server-repo/datasource.properties
COPY config/properties/acmEmailSender.properties /root/.arkcase/acm/acm-config-server-repo/acmEmailSender.properties
COPY config/properties/arkcase-activemq.properties /root/.arkcase/acm/acm-config-server-repo/arkcase-activemq.properties
# Modify server.xml for SSL and APR configuration
RUN sed -i 's|<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on"/>|<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" useAprConnector="true"/>|' /usr/local/tomcat/conf/server.xml

# Add SSL Connector configuration to server.xml
RUN sed -i '/<\/Service>/i \<Connector port="8843" maxThreads="150" SSLEnabled="true" secure="true" scheme="https" maxHttpHeaderSize="32768" connectionTimeout="40000" useBodyEncodingForURI="true" address="0.0.0.0"> <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" /> <SSLHostConfig protocols="TLSv1.2" certificateVerification="none"> <Certificate certificateFile="/root/.arkcase/acm/private/acm-arkcase.crt" certificateKeyFile="/root/.arkcase/acm/private/acm-arkcase.rsa.pem" certificateChainFile="/root/.arkcase/acm/private/arkcase-ca.crt" type="RSA" /> </SSLHostConfig> </Connector>' /usr/local/tomcat/conf/server.xml

# RUN the converter.sh
COPY config/converter.sh /usr/local/tomcat/converter.sh
RUN chmod +x /usr/local/tomcat/converter.sh

CMD /usr/local/tomcat/converter.sh

# Expose the default port for Tomcat
EXPOSE 8080
EXPOSE 443
EXPOSE 8983
#EXPOSE 61613
EXPOSE 61616
EXPOSE 9999

# Start the Config Server and Tomcat
CMD java -jar /usr/local/tomcat/config-server.jar & catalina.sh run
