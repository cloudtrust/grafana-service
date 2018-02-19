## Grafana Service
##Plug this on an influx to graphically view the data.

```Bash
cd /cloudtrust
#Get the repo
git clone git@github.com:cloudtrust/grafana-service.git

cd grafana-service

#install systemd unit file
install -v -o root -g root -m 644  deploy/common/etc/systemd/system/cloudtrust-grafana@.service /etc/systemd/system/cloudtrust-grafana@.service

mkdir build_context
cp dockerfiles/cloudtrust-grafana.dockerfile build_context/
cd build_context

#Build the dockerfile for DEV environment
docker build --build-arg branch=master -t cloudtrust-grafana:f27 -t cloudtrust-grafana:latest -f cloudtrust-grafana.dockerfile .

#create container 1
docker create -p 9090:80 --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name grafana-1 cloudtrust-grafana

systemctl daemon-reload
#start container DEV1
systemctl start cloudtrust-grafana@1

## Configure grafana
# Create and populate database. The influx-service container runs with ip 172.17.0.2.
python3.6 createAndPopulateInfluxdb.py --host "172.17.0.2" --port "80"

# Configure data source. The grafana-service container runs with ip ip 172.17.0.3.
# Here we create am indlux datasource named influxdb-cloudtrust that fetch data from the database named cloudtrust_grafana_test
curl 'http://admin:admin@172.17.0.3:80/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"influxdb-cloudtrust","type":"influxdb","url":"http://localhost:8086","access":"proxy","isDefault":true,"database":"cloudtrust_grafana_test","user":"jdr","password":"jdr"}'
# Access Grafana with user=admin, pwd=admin
firefox --new-window http://172.17.0.3:80
```

