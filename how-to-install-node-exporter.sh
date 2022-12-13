## How to install node_exporter as service
# Creating service user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Download node_exporter 
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz

sudo tar xvf node_exporter-1.5.0.linux-amd64.tar.gz

sudo cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin

# Set user and group ownership to node_exporter user
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Delete downloaded file
rm -rf node_exporter-1.5.0.linux-amd64.tar.gz node_exporter-1.5.0.linux-amd64

# Create service for node_exporter
cat <<EOF sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Add node_exporter to prometheus service 
cat <<EOF sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
...
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['## localhost ## :9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']     
EOF

sudo systemctl restart prometheus
sudo systemctl status prometheus

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Ref : 
## https://www.digitalocean.com/community/tutorials/how-to-install-prometheus-on-ubuntu-16-04
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
