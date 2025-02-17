#Give actual value of token before running this file
# oc login https://masterdnsj2p5wq2nzrzvo.southindia.cloudapp.azure.com:443 --token=
oc login --token=sha256~U4VusVXd-qC_RjeTCuAHzXzCPDdv8C3JMmVB5g51HVo --server=https://api.shared-410.openshift.redhatworkshops.io:6443

oc new-project springboot-mongo-demo-cicd

oc new-app -f jenkins_template.json -e INSTALL_PLUGINS=configuration-as-code-support,credentials:2.1.16,matrix-auth:2.3,sonar,nodejs,ssh-credentials,jacoco -e CASC_JENKINS_CONFIG=https://raw.githubusercontent.com/sourabhgupta385/openshift-jenkins/master/jenkins.yaml -n springboot-mongo-demo-cicd

oc new-app -f sonarqube-ephemeral-template.json -n springboot-mongo-demo-cicd

oc new-app mongo:3.4 --name=orders-db -n springboot-mongo-demo-cicd

oc new-project springboot-mongo-demo-dev
oc new-project springboot-mongo-demo-test
oc new-project springboot-mongo-demo-prod

oc new-app  mongo:3.4 --name=orders-db -n springboot-mongo-demo-dev
oc new-app  mongo:3.4 --name=orders-db -n springboot-mongo-demo-test
oc new-app  mongo:3.4 --name=orders-db -n springboot-mongo-demo-prod

oc policy add-role-to-user system:image-puller system:serviceaccount:springboot-mongo-demo-test:default -n springboot-mongo-demo-dev
oc policy add-role-to-user system:image-puller system:serviceaccount:springboot-mongo-demo-prod:default -n springboot-mongo-demo-dev

oc policy add-role-to-user edit system:serviceaccount:springboot-mongo-demo-cicd:jenkins -n springboot-mongo-demo-dev
oc policy add-role-to-user edit system:serviceaccount:springboot-mongo-demo-cicd:jenkins -n springboot-mongo-demo-test
oc policy add-role-to-user edit system:serviceaccount:springboot-mongo-demo-cicd:jenkins -n springboot-mongo-demo-prod

oc new-app https://github.com/sourabhgupta385/sample-springboot-mongo-app.git --strategy=pipeline --name=springboot-mongo-demo-pipeline -n springboot-mongo-demo-cicd
