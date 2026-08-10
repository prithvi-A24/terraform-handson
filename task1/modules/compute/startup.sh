#!/bin/bash
set -e

# Log all output for debugging
exec > >(tee /var/log/startup-script.log | logger -t startup-script) 2>&1

echo "===== Starting VM initialization ====="

# Update packages
apt-get update -y

# Install required packages
apt-get install -y nginx curl

# Enable and start NGINX
systemctl enable nginx
systemctl start nginx

# Fetch metadata
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/name)

INSTANCE_ID=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/id)

ZONE=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $NF}')

MACHINE_TYPE=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/machine-type | awk -F/ '{print $NF}')

INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

START_TIME=$(date)

# Create the web page
cat <<EOF >/var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Google Cloud Load Balancer Demo</title>
<style>
body{
    font-family:Arial,sans-serif;
    background:#f4f4f4;
    text-align:center;
    margin-top:60px;
}
table{
    margin:auto;
    border-collapse:collapse;
}
td,th{
    border:1px solid #ccc;
    padding:12px 20px;
}
th{
    background:#4285F4;
    color:white;
}
h1{
    color:#34A853;
}
</style>
</head>

<body>

<h1>Google Cloud Load Balancer Demo</h1>

<table>
<tr><th>Property</th><th>Value</th></tr>
<tr><td>Instance Name</td><td>$INSTANCE_NAME</td></tr>
<tr><td>Instance ID</td><td>$INSTANCE_ID</td></tr>
<tr><td>Zone</td><td>$ZONE</td></tr>
<tr><td>Machine Type</td><td>$MACHINE_TYPE</td></tr>
<tr><td>Internal IP</td><td>$INTERNAL_IP</td></tr>
<tr><td>Startup Time</td><td>$START_TIME</td></tr>
</table>

<p><b>Refresh this page to see requests served by different instances.</b></p>

</body>
</html>
EOF

echo "===== Startup completed successfully ====="