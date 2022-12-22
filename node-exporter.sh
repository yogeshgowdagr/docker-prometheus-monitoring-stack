#!/bin/bash

## removing if apt installed is present 

promserver=10.64.238.12   ### change this accoring to you prometheus server 
port=9100
ver=1.3.1  ## change version according to you 
apt remove -y  prometheus-node-exporter 
cd 

touch node_export

cat > node_export <<EOF
[Unit]
Description=Node exporter to collect machine metrics

[Service]
Restart=always
User=prometheus
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:$port
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

echo "checking if $port is being used "
sleep 2
nc -z 127.0.0.1 $port

nexp=$?

if [ $nexp -ne 0 ]; then
    cd
    sleep 5 
    echo "   Installing Node_exporter"
    sleep 5
    wget https://github.com/prometheus/node_exporter/releases/download/v$ver/node_exporter-$ver.linux-amd64.tar.gz
    tar -xvf node_exporter-$ver.linux-amd64.tar.gz
    mv node_exporter-$ver.linux-amd64 node_exporter
    sudo useradd --system --no-create-home --shell /usr/sbin/nologin prometheus
    cd node_exporter
    mv node_exporter /usr/local/bin/.
    sudo chown prometheus:prometheus /usr/local/bin/node_exporter
    cd 
    cat  node_export > /etc/systemd/system/node_exporter.service 
    sudo systemctl daemon-reload
    rm -rf node_exporter-$ver.linux-amd64.tar.gz ## removing downloaded files 
    rm -rf node_export*  #removing service install helper file 
    sudo systemctl restart node_exporter.service
    sudo systemctl enable node_exporter.service
    sudo systemctl status node_exporter.service  
else
    sleep 1
    echo "ERROR : $port port is being used cannot continue . If you want this to be installed in another port specifiy  in the variable at starting"
    sleep 5 
fi

iptables -A INPUT -p tcp -s $promserver --dport $port -j ACCEPT
iptables -I INPUT -p tcp -s $promserver --dport $port -j ACCEPT


