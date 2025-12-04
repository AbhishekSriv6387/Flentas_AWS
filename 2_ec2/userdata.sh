#!/bin/bash
# EC2 Web Server Setup Script

# Update system
yum update -y

# Install Nginx
yum install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create index.html with resume content
cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${first_name_last_name} - Resume</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        h2 {
            color: #007bff;
            margin-top: 25px;
        }
        .section {
            margin-bottom: 20px;
        }
        .contact-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .skills {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .skill {
            background-color: #007bff;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>${first_name_last_name}</h1>
        
        <div class="contact-info">
            <strong>Email:</strong> ${first_name_last_name}@example.com<br>
            <strong>Phone:</strong> (555) 123-4567<br>
            <strong>Location:</strong> AWS Cloud, us-east-1<br>
            <strong>LinkedIn:</strong> linkedin.com/in/${first_name_last_name}
        </div>

        <div class="section">
            <h2>Professional Summary</h2>
            <p>Experienced cloud engineer with expertise in AWS infrastructure, DevOps practices, and automation. 
            Demonstrated ability to design, implement, and maintain scalable cloud solutions. Strong background in 
            infrastructure as code, continuous integration/deployment, and system administration.</p>
        </div>

        <div class="section">
            <h2>Technical Skills</h2>
            <div class="skills">
                <span class="skill">AWS</span>
                <span class="skill">Terraform</span>
                <span class="skill">Linux</span>
                <span class="skill">Docker</span>
                <span class="skill">Kubernetes</span>
                <span class="skill">Python</span>
                <span class="skill">Bash</span>
                <span class="skill">Jenkins</span>
                <span class="skill">Git</span>
                <span class="skill">Nginx</span>
            </div>
        </div>

        <div class="section">
            <h2>Professional Experience</h2>
            <h3>Senior Cloud Engineer - Tech Company</h3>
            <p><em>2021 - Present</em></p>
            <ul>
                <li>Designed and implemented AWS infrastructure using Terraform</li>
                <li>Managed multi-tier applications with auto-scaling and load balancing</li>
                <li>Implemented CI/CD pipelines for automated deployments</li>
                <li>Reduced infrastructure costs by 30% through optimization</li>
            </ul>

            <h3>DevOps Engineer - Startup Inc.</h3>
            <p><em>2019 - 2021</em></p>
            <ul>
                <li>Built containerized applications using Docker and Kubernetes</li>
                <li>Implemented monitoring and alerting solutions</li>
                <li>Automated infrastructure provisioning and configuration</li>
                <li>Improved deployment frequency by 200%</li>
            </ul>
        </div>

        <div class="section">
            <h2>Education</h2>
            <p><strong>Bachelor of Science in Computer Science</strong><br>
            University Name, 2019</p>
        </div>

        <div class="section">
            <h2>Certifications</h2>
            <ul>
                <li>AWS Solutions Architect Associate</li>
                <li>AWS Developer Associate</li>
                <li>HashiCorp Terraform Associate</li>
            </ul>
        </div>

        <div class="section">
            <h2>Projects</h2>
            <h3>AWS Infrastructure Assessment</h3>
            <p>Designed and implemented a complete AWS infrastructure including VPC with public/private subnets, 
            NAT instance, EC2 web server with Nginx, Auto Scaling Group with Application Load Balancer, 
            and CloudWatch billing monitoring. This project demonstrates expertise in cloud architecture, 
            infrastructure as code, and AWS best practices.</p>
        </div>

        <div class="section" style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
            <p><em>Deployed on AWS EC2 using Terraform • $${new Date().toLocaleDateString()}</em></p>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chmod 644 /usr/share/nginx/html/index.html

# Configure Nginx
sed -i 's/#server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf

# Harden SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure automatic security updates
yum install -y yum-cron
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
systemctl enable yum-cron
systemctl start yum-cron

# Create setup completion log
echo "Web server setup completed successfully" > /var/log/web-setup.log
echo "Website deployed for ${first_name_last_name}" >> /var/log/web-setup.log
echo "Deployment date: $(date)" >> /var/log/web-setup.log