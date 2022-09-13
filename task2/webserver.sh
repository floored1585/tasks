#! /bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start
sudo echo '<h1>Homework App</h1>' > /var/www/html/index.html
