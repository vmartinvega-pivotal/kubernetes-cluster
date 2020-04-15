helm repo add bitnami https://charts.bitnami.com/bitnami
helm install jenkins bitnami/jenkins \
       --set global.storageClass=gluster-heketi-external \
			 --set persistence.storageClass=gluster-heketi-external \
			 --set persistence.size=2Gi
