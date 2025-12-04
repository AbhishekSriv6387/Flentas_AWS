#!/bin/bash
# Simple ASG Userdata
yum update -y
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

# Create index.html
cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Krish_Maheshwari - ASG</title>
</head>
<body>
    <h1>Krish_Maheshwari</h1>
    <p>Auto Scaling Group Demo</p>
    <p>Deployed via Terraform</p>
</body>
</html>
EOF

chmod 644 /usr/share/nginx/html/index.html