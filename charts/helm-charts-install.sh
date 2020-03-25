# Informacion cogida de aqui
#
# https://docs.bitnami.com/tutorials/integrate-logging-kubernetes-kibana-elasticsearch-fluentd/


helm repo add bitnami https://charts.bitnami.com/bitnami

helm install elasticsearch bitnami/elasticsearch \
             --set global.storageClass=gluster-heketi-external \
			 --set master.persistence.size=2Gi \
			 --set data.persistence.size=2Gi

helm install kibana bitnami/kibana \
  --set elasticsearch.enabled=false \
  --set elasticsearch.hosts[0]=elasticsearch-elasticsearch-coordinating-only.default.svc.cluster.local \
  --set elasticsearch.port=9200 \
  --set service.type=LoadBalancer \
  --set global.storageClass=gluster-heketi-external \
  --set presistence.storageClass=gluster-heketi-external \
  --set persistence.size=2Gi
  
kubectl create -f elasticsearch-output.yaml
kubectl create -f apache-log-parser.yaml

helm install fluentd bitnami/fluentd \
  --set aggregator.configMap=elasticsearch-output \
  --set forwarder.configMap=apache-log-parser \
  --set aggregator.extraEnv[0].name=ELASTICSEARCH_HOST \
  --set aggregator.extraEnv[0].value=elasticsearch-elasticsearch-coordinating-only.default.svc.cluster.local \
  --set aggregator.extraEnv[1].name=ELASTICSEARCH_PORT \
  --set-string aggregator.extraEnv[1].value=9200 \
  --set forwarder.extraEnv[0].name=FLUENTD_DAEMON_USER \
  --set forwarder.extraEnv[0].value=root \
  --set forwarder.extraEnv[1].name=FLUENTD_DAEMON_GROUP \
  --set forwarder.extraEnv[1].value=root
  
helm install wordpress bitnami/wordpress \
  --set global.storageClass=gluster-heketi-external \
  --set persistence.storageClass=gluster-heketi-external \
  --set persistence.size=2Gi \
  --set mariadb.master.persistence.size=2Gi
  
helm install tomcat bitnami/tomcat \
  --set global.storageClass=gluster-heketi-external \
  --set persistence.storageClass=gluster-heketi-external \
  --set persistence.size=2Gi
  
