# 2APPAI1 - Linux Webservices - Shipping Challenge 2020

- **Name**: Van Gestel Axel
- **Class**: 2 APPAI 1
- **Studentnr**: r0784084
- **DockerHub**: [johanaxel007/shipping-challenge](https://hub.docker.com/repository/docker/johanaxel007/shipping-challenge)

## Stack
- **Webserver**: Apache2
- **Database**: MySQL
- **Script Language**: Perl
- **Extra**: Portainer

## Installation
### Minikube
- Installed on Minikube on Windows 10 with the Ingress plugin enabled.
    - `minikube start`
    - `minikube addons enable ingress`
- Install Helm 3 and add Bitnami Helm repo.
    - [Helm | Installing Helm](https://helm.sh/docs/intro/install/)
    - `helm repo add bitnami https://charts.bitnami.com/bitnami`
  
### Shipping Challenge
- Setup MySQL using Helm.
   -  `helm install sc-mysql bitnami/mysql --set auth.password=admin1234 --set auth.username=shipping_challenge --set auth.database=shipping_challenge`
- Apply deployment.yaml, service.yaml and ingress.yaml using:
    - `kubectl apply -f deployment.yaml`
    - `kubectl apply -f service.yaml`
    - `kubectl apply -f ingress.yaml`
- Get the Ingress IP Address (under `ADDRESS`).
    - `kubectl get ingress`
- Add the IP to your HOST File.
    - Windows example: `192.168.99.102 shipping-challenge.local`
- Open your browser and surf to `shipping-challenge.local`.
    - Remark: If you get a database error you should change the `$db_ip` in the .pl scripts to the new `sc-mysql` service `cluster IP`
### Portainer
- Add the Portainer Helm repo.
   - `helm repo add portainer https://portainer.github.io/k8s/`
   - `helm repo update`
- Create the Portainer namespace in your cluster.
   - `kubectl create namespace portainer`
- Deploy Portainer for Ingress.
   - `helm install -n portainer portainer portainer/portainer --set service.type=ClusterIP`
- Expose Portainer for use on your Host PC.
  - **Remark:** Run the following commands in a `Bach terminal` (for example: `Git Bash`)
  - `export POD_NAME=$(kubectl get pods --namespace portainer -l "app.kubernetes.io/name=portainer,app.kubernetes.io/instance=portainer" -o jsonpath="{.items[0].metadata.name}")`
  - `echo "Visit http://127.0.0.1:9000 to use your application"`
  - `kubectl --namespace portainer port-forward $POD_NAME 9000:9000`
- You can now open a Portainer tab
    - http://127.0.0.1:9000
  
## Sources
### Apache2 + Perl
  - https://github.com/pclinger/docker-apache-perl
  - https://techexpert.tips/apache/perl-cgi-apache/
  - https://www.mirantis.com/blog/how-do-i-create-a-new-docker-image-for-my-application/
  - https://codefresh.io/docker-tutorial/build-docker-image-dockerfiles/

###Perl Script
  - Dynamic get server IP
    - https://www.tek-tips.com/faqs.cfm?fid=3509
    - https://docstore.mik.ua/orelly/perl4/cook/ch18_02.htm
  - General Perl Stuff
    - https://www.yourhtmlsource.com/cgi/perlvariables.html
    - https://www.sitepoint.com/community/t/please-explain-how-to-use-eof/1531/2
    - https://perlmaven.com/here-documents
  - Perl Debugging
    - https://www.perlmonks.org/?node_id=10867
    - https://metacpan.org/pod/CGI::Carp
  - MySQL stuff
    - https://metacpan.org/pod/DBD::mysql
    - https://www.mysqltutorial.org/perl-mysql/
    - https://www.mysqltutorial.org/perl-mysql/perl-mysql-update-data/
    - https://www.w3schools.com/sql/sql_autoincrement.asp
  - User Input Forms
    - https://www.tutorialspoint.com/perl/perl_cgi_programming.htm
  - IF ELSE Syntax
    - https://alvinalexander.com/blog/post/perl/perl-if-else-elsif-syntax-example/

### My SQL
  - https://github.com/bitnami/charts/tree/master/bitnami/mysql

### Docker Repository
  - https://docs.docker.com/docker-hub/repos/
  - https://docs.docker.com/docker-hub/builds/

### Kubernetes
  - MySQL + Networking setup
    - https://github.com/meyskens/intro-to-k8s/tree/main/wordpress
  - Ingress File
    - https://kubernetes.io/docs/concepts/services-networking/ingress/
  - Deployment File
    - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

### Portainer
  - https://documentation.portainer.io/v2.0/deploy/linux/
  - https://github.com/portainer/portainer-k8s/blob/master/charts/portainer-beta/README.md