# docker-prometheus-monitoring-stack

Note : Run the scripts as a root user if you are installing as a service .

Clone the REPO
```
git clone https://github.com/yogeshgowdagr/monitoring.git

```
get inside the folder 
```
cd monitoring
```
In Simple way,  Use `docker-compose up -d` to bring up the stack with grafana-prometheus-alertmanager-balckboxexporter-cadvisor

*Note* 
```
Grafana Logins
user : admin
Pass : Admin$1199
```
go to `localhost:3000` to check grafana 
```

`alertmanager.yml`>`alertmanagerconfig`

`config.yml`>`blackbox config`

`promdata/alert.rules.yml`>`alerting rules`

`prometheus.yml`>`Prometheus configuration`

```

# Scripts 
## Node Exporter 

Install this in all of your servers to collect metrics

*Note: You need to change the IP of prometheus server in `node-exporter.sh`*
You can also change the port if you want node exporter to run in different port 

How to get node exporter installed 
```
chmod +x node-exporter.sh
sudo su 
```
```
./node-exporter.sh
```

## Prometheus

The Added Script is a One time instalation script , you can also use same to run in different port .
```
chmod +x prometheus.sh
sudo su 
```
Note You need to add your server IP's in scrape configs 
```
./prometheus.sh
```


