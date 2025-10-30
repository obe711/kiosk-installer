#!/bin/sh

sudo apt-get update 
sudo apt-get install avahi-daemon nginx -y

sudo mkdir -p /var/www/nexus-dashboard.local/html
sudo chown -R nexus:nexus /var/www/nexus-dashboard.local/html

sudo tee /etc/nginx/sites-available/nexus-dashboard.local << 'EOF'
# Dashboard server configuration
#
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/nexus-dashboard.local/html;

        # Add index.php to the list if you are using PHP
	      index index.html;

	      server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
}
EOF

if [ -L /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Remove existing symbolic link if it exists
if [ -L /etc/nginx/sites-enabled/nexus-dashboard.local ]; then
    sudo rm /etc/nginx/sites-enabled/nexus-dashboard.local
fi

sudo ln -s /etc/nginx/sites-available/nexus-dashboard.local /etc/nginx/sites-enabled/nexus-dashboard.local

sudo systemctl restart nginx
