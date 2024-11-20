#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Check if Nginx was installed successfully
if ! command -v nginx &> /dev/null; then
    echo "Nginx installation failed."
    exit 1
fi

# Enable and start Nginx service
echo "Starting and enabling Nginx service..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a custom welcome page
WELCOME_PAGE="/var/www/html/index.html"
echo "Creating custom welcome page..."

sudo tee "$WELCOME_PAGE" > /dev/null <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Nginx!</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #4CAF50; }
    </style>
</head>
<body>
    <h1>Welcome to My Custom Nginx Server!</h1>
    <p>This is a custom welcome page.</p>
</body>
</html>
EOL

# Restart Nginx to apply changes
echo "Restarting Nginx to apply changes..."
sudo systemctl restart nginx

# Confirm successful setup
echo "Custom Nginx welcome page setup complete. Visit http://localhost to see it."
