
echo "Environment variables before substitution:"

# Create Keystore files and Others
echo "Creating keystore files"
# CHECK KEY STORE PASSWORD IS ALREADY SET OR NOT
if [ -z "$KEY_STORE_PASSWORD" ]; then
    echo "Key store password is not set. Setting default password"
    export KEY_STORE_PASSWORD=arkcase
fi

# Set paths
PRIVATE_DIR="/root/.arkcase/acm/private"

echo "Removing existing files in $PRIVATE_DIR ..."

# Remove all files in the directory
# shellcheck disable=SC2115
rm -rf "$PRIVATE_DIR"/*

# Optionally, if you also want to remove subdirectories, use `-r` (recursive):
# rm -rf "$PRIVATE_DIR"/*

echo "Files removed successfully."
env TEST="wdejdewjdewjje"
# Define environment variables
export KEY_PATH="/root/.arkcase/acm/private/arkcase.key.pem"
export CERT_PATH="/root/.arkcase/acm/private/arkcase.cert.pem"
export CA_CHAIN_PATH="/root/.arkcase/acm/private/ca-chain.cert.pem"
export KEYSTORE_PATH="/root/.arkcase/acm/private/arkcase.ks"
export TRUSTSTORE_PATH="/root/.arkcase/acm/private/arkcase.ts"
export CSR_PATH="/root/.arkcase/acm/private/arkcase.csr.pem"
export KEYSTORE12_PATH="/root/.arkcase/acm/private/arkcase.p12"
export CA_KEY_PATH="/root/.arkcase/acm/private/ca.key.pem"
export KEY_STORE_PASSWORD=arkcase
export CUSTOM_OPENSSL_CONF="/root/.arkcase/acm/private/custom_openssl.cnf"




# Create necessary directories and files for OpenSSL CA
mkdir -p /root/.arkcase/acm/private/newcerts /root/.arkcase/acm/private/certs /root/.arkcase/acm/private/crl
touch /root/.arkcase/acm/private/index.txt
echo 1000 > /root/.arkcase/acm/private/serial

# Create custom OpenSSL configuration file
# Create custom OpenSSL configuration file
cat > $CUSTOM_OPENSSL_CONF <<EOL
[ ca ]
default_ca = CA_default

[ CA_default ]
dir             = /root/.arkcase/acm/private           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.
new_certs_dir   = \$dir/newcerts         # default place for new certs.
certificate     = \$dir/ca-chain.cert.pem       # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
crl             = \$dir/crl.pem          # The current CRL
private_key     = \$dir/ca.key.pem       # The private key
RANDFILE        = \$dir/private/.rand    # private random number file
x509_extensions = v3_ca
default_days    = 3650
default_md      = sha256
preserve        = no
policy          = policy_anything
email_in_dn     = no
rand_serial     = yes

[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
x509_extensions     = v3_ca

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = US
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = New York
localityName                = Locality Name (eg, city)
localityName_default        = New York
0.organizationName          = Organization Name (eg, company)
0.organizationName_default  = Example Corp
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_default          = example.com
commonName_max              = 64

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true

[ policy_anything ]
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOL

# Ensure correct permissions
chmod 755 /root/.arkcase/acm/private/
chmod 777 /root/.arkcase/acm/private/

# Create CA private key and certificate
echo "Creating CA private key... 1"
openssl genrsa -aes256 -out "$CA_KEY_PATH" -passout pass:"$KEY_STORE_PASSWORD" 2048

echo "Creating CA certificate..."
openssl req -config "$CUSTOM_OPENSSL_CONF" -key "$CA_KEY_PATH" -new -x509 -days 3650 -sha256 -extensions v3_ca -out "$CA_CHAIN_PATH" -passin pass:"$KEY_STORE_PASSWORD" -subj "/C=US/ST=New York/L=New York/O=Example Corp/CN=example.com CA"

# Create private key for the server certificate
echo "Creating private key for the server certificate..."
openssl genrsa -aes256 -out "$KEY_PATH" -passout pass:"$KEY_STORE_PASSWORD" 2048


# Create CSR for server certificate
echo "Creating certificate signing request (CSR)..."
openssl req -config "$CUSTOM_OPENSSL_CONF" -key "$CA_KEY_PATH" -new -sha256 -out "$CSR_PATH" -passin pass:"$KEY_STORE_PASSWORD" -passout pass:"$KEY_STORE_PASSWORD" -subj "/C=US/ST=New York/L=New York/O=Example Corp/CN=example.com"

# Sign server certificate with CA
echo "Signing server certificate..."
openssl ca -config "$CUSTOM_OPENSSL_CONF" -extensions server_cert -days 3650 -notext -md sha256 -in "$CSR_PATH" -out "$CERT_PATH" -passin pass:"$KEY_STORE_PASSWORD" -keyfile "$CA_KEY_PATH" -cert "$CA_CHAIN_PATH" -outdir "/root/.arkcase/acm/private/" -batch

# Create keystore
# Create PKCS12 keystore
echo "Creating PKCS12 keystore..."
openssl pkcs12 -export -in "$CERT_PATH" -inkey "$CA_KEY_PATH" -out "$KEYSTORE12_PATH" -name arkcase -CAfile "$CA_CHAIN_PATH" -caname root -chain -passout pass:"$KEY_STORE_PASSWORD" -passin pass:"$KEY_STORE_PASSWORD"

# Convert PKCS12 keystore to JKS keystore
echo "Converting PKCS12 keystore to JKS..."
keytool -importkeystore -srckeystore "$KEYSTORE12_PATH" -srcstoretype PKCS12 -destkeystore "$KEYSTORE_PATH" -deststoretype JKS -storepass "$KEY_STORE_PASSWORD" -srcstorepass "$KEY_STORE_PASSWORD"

# Create truststore
echo "Creating truststore..."
keytool -importcert -alias arkcase -keystore "$TRUSTSTORE_PATH" -file "$CA_CHAIN_PATH" -storepass "$KEY_STORE_PASSWORD" -noprompt
keytool -importcert -alias ldap -keystore "$TRUSTSTORE_PATH" -file "$CA_CHAIN_PATH" -storepass "$KEY_STORE_PASSWORD" -noprompt

# Import intermediate certificate into truststore (assuming it's needed)
echo "Importing intermediate certificate into truststore..."
keytool -importcert -alias arkcaseIntermediate -keystore "$TRUSTSTORE_PATH" -file "$CERT_PATH" -storepass "$KEY_STORE_PASSWORD"

# SET JAVA_OPTS
export JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Duser.timezone=GMT \
  -Djavax.net.ssl.keyStorePassword=$KEY_STORE_PASSWORD \
  -Djavax.net.ssl.trustStorePassword=$KEY_STORE_PASSWORD \
  -Djavax.net.ssl.keyStore=$KEYSTORE_PATH \
  -Djavax.net.ssl.trustStore=$TRUSTSTORE_PATH \
  -Dspring.profiles.active=ldap \
  -Dacm.configurationserver.propertyfile=/root/.arkcase/acm/conf.yml \
  -Djava.security.egd=file:/dev/./urandom \
  -Djava.util.logging.config.file=/root/.arkcase/acm/log4j2.xml \
    -Dconfiguration.client.spring.path=/root/.arkcase/acm/acm-config-server-repo/spring/auditPatterns.properties \
  -Xms1024M -Xmx1024M"

# Print environment variables before substitution
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

envsubst < /usr/local/tomcat/conf/server.xml > /usr/local/tomcat/conf/server.xml.tmp
mv /usr/local/tomcat/conf/server.xml.tmp /usr/local/tomcat/conf/server.xml

echo /usr/local/tomcat/conf/server.xml

echo  "Test if the Key tools are fine"
keytool -list -keystore "$KEYSTORE_PATH" -storepass "$KEY_STORE_PASSWORD"



