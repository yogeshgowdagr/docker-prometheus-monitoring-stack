#!/bin/bash

##removing apt installed version of prometheus  
sudo apt remove prometheus -y 

port=9090
ver=2.36.1  ## change version according to you 

cd ~ || exit

cat > prometheus.service <<EOF
[Unit]
Description=Monitoring system and time series database
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /etc/prometheus/data  \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries --storage.tsdb.retention.time=1y --web.listen-address=0.0.0.0:$port

ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no
LimitNOFILE=8192

[Install]
WantedBy=multi-user.target
EOF

cat > prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 'localhost:9093'
rule_files:
  - alert.rules.yml
scrape_configs:
  - job_name: "prometheus_master"
    scrape_interval: 5s
    static_configs:
      - targets: ["localhost:9090"]
  - job_name: 'Nodes'
    scrape_interval: 5s
    static_configs:
      - targets: ["node_exporter:9100"]
  - job_name: 'Site Monitoring'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://id-poc.dhi-edu.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115
  - job_name: 'Internal Service Monitoring via Tcp '
    scrape_timeout: 15s
    scrape_interval: 15s
    metrics_path: /probe
    params:
      module: [tcp_connect]
    static_configs:
      - targets:
          - localhost:9090
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115
EOF

echo "checking if $port is being used "
sleep 2
nc -z 127.0.0.1 $port

nexp=$?

if [ $nexp -ne 0 ]; then
    cd ~ || exit
    sleep 5 
    echo "   Installing Pormetheus"
    sleep 5
    wget https://github.com/prometheus/prometheus/releases/download/v$ver/prometheus-$ver.linux-amd64.tar.gz
    tar -xvf prometheus-$ver.linux-amd64.tar.gz
    mv prometheus-$ver.linux-amd64 prometheus
    mv prometheus /etc/prometheus
    mv /etc/prometheus/prometheus /usr/local/bin/.
    mv ~/prometheus.yml /etc/prometheus/.
    mkdir /etc/prometheus/data
    chown -R prometheus:prometheus /etc/prometheus
    chmod -R 755 /etc/prometheus
    cat prometheus.service > /etc/systemd/system/prometheus.service
    cd ~ || exit
    rm -rf prometheus*
    sudo systemctl daemon-reload
    sudo systemctl restart prometheus.service
    sudo systemctl enable prometheus.service
    sudo systemctl status prometheus.service


else
    sleep 1
    echo "ERROR : $port port is being used cannot continue . If you want this to be installed in another port specifiy  in the variable at starting"
    sleep 5 
fi

cd ~ || exit
rm -rf prometheus*

iptables -A INPUT -p tcp --dport $port -j ACCEPT
iptables -I INPUT -p tcp --dport $port -j ACCEPT
