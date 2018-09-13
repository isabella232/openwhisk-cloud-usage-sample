PLAN=lite # standard | lite
PREFIX=usage-tutorial
REGION=us-south

CLOUD_OBJECT_STORAGE=$(PREFIX)-cos
COGNOS_DASHBOARD=$(PREFIX)-cognos
SQL_QUERY=$(PREFIX)-sql

bind-services:
	ibmcloud fn service bind cloud-object-storage cloud-object-storage --instance $(CLOUD_OBJECT_STORAGE)
	ibmcloud fn service bind dynamic-dashboard-embedded openwhisk-cognos-dashboard --instance $(COGNOS_DASHBOARD)

create-services:
	ibmcloud resource service-instance-create $(CLOUD_OBJECT_STORAGE) cloud-object-storage $(PLAN) global -t $(PREFIX)
	ibmcloud resource service-key-create $(CLOUD_OBJECT_STORAGE)-creds Writer --instance-name $(CLOUD_OBJECT_STORAGE) --parameters '{"HMAC":true}'
	ibmcloud resource service-instance-create $(SQL_QUERY) sql-query $(PLAN) $(REGION) -t $(PREFIX)
	ibmcloud resource service-instance-create $(COGNOS_DASHBOARD) dynamic-dashboard-embedded $(PLAN) $(REGION) -t $(PREFIX)
	ibmcloud resource service-key-create $(COGNOS_DASHBOARD)-creds Viewer --instance-name $(COGNOS_DASHBOARD)

remove-services:
	ibmcloud resource service-key-delete $(COGNOS_DASHBOARD)-creds
	ibmcloud resource service-key-delete $(CLOUD_OBJECT_STORAGE)-creds
	ibmcloud resource service-instance-delete $(CLOUD_OBJECT_STORAGE)
	ibmcloud resource service-instance-delete $(SQL_QUERY)
	ibmcloud resource service-instance-delete $(COGNOS_DASHBOARD)

download-wskdeploy:
	curl -L https://github.com/apache/incubator-openwhisk-wskdeploy/releases/download/0.9.8-incubating/openwhisk_wskdeploy-0.9.8-incubating-mac-386.zip --output wskdeploy.zip
	tar -zxvf wskdeploy.zip wskdeploy
	rm wskdeploy.zip

deploy:
	wskdeploy -m tutorial-etl-request.yaml
	wskdeploy -m tutorial-etl-process.yaml
	wskdeploy -m tutorial-etl-query.yaml
	wskdeploy -m tutorial-etl-dashboard.yaml

undeploy:
	wskdeploy undeploy -m tutorial-etl-request.yaml
	wskdeploy undeploy -m tutorial-etl-process.yaml
	wskdeploy undeploy -m tutorial-etl-query.yaml
	wskdeploy undeploy -m tutorial-etl-dashboard.yaml

update-request:
	wskdeploy -m tutorial-etl-request.yaml

update-process:
	wskdeploy -m tutorial-etl-process.yaml

update-query:
	wskdeploy -m tutorial-etl-query.yaml

update-dashboard:
	wskdeploy -m tutorial-etl-dashboard.yaml



