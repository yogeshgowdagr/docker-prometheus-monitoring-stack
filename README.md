# monitoring

```
git clone https://github.com/yogeshgowdagr/monitoring.git

```
get inside the folder 
```
cd monitoring
```
## Node Exporter 

Install this in all of you servers to collect metrics

Note: You need to change the IP of prometheus server in `node-exporter.sh`
You can also change the port if you want node exporter to run in different port 

How to get node exporter installed 
```
chmod +x node-exporter.sh
```
```
./node-exporter.sh
```

## Prometheus

The Added Script is a One time instalation script , you can also use same to run in different port .
```
chmod +x prometheus.sh
```
Note You need to add your server IP's in scrape configs 
```
./prometheus.sh
```
