# 2APPAI1 - Linux Webservices - Shipping Challenge 2020

- **Name**: Van Gestel Axel
- **Class**: 2 APPAI 1
- **Studentnr**: r0784084

## My Stack
| **Webserver** | **Database** | **Script Language** |   **Extra**   |
|:-------------:|:------------:|:-------------------:|:-------------:|
|    Apache2    |     MySQL    |         Perl        |   Portainer   |

## The Challenge
- Create your own kubernetes stack with 1 worker.
- Containerized application on worker is the following.
    ![Challenge](docs/challenge.png)
    - When surname changes in Db, webpage changes automatically.
    - When  layout of webpage changes, the worker will display the new layout automatically.
    - Use the webstack which is assigned to you.

### How to earn points?
- 0/20 - be like Homer Simpson or Al Bundy
- 10/20 - stack in Docker
- 14/20 - mk8s cluster with 1 worker

### Extra points
- Vagrant
- Extra worker
- Management webplatform for containers, see Extra in [My Stack](#my-stack).
- Something else than mk8s with the same purpose.

### Nice to haves - Fun Factor
- A practical linux joke for docents.
- A linux koan to enlighten your docents.

## My Setup
### Dockerfile
```Dockerfile
# The line below states we will base our new image on the Latest Official Ubuntu 
FROM ubuntu:20.04
# labels
LABEL version="0.8.0"

# Pre-configure timezone to stop hang during build
ENV TZ=Europe/Brussels
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update the image to the latest packages
RUN	apt-get update && apt-get upgrade -y \
	&& apt-get clean -y

# Install Apache2 and Perl, enable cgid and disable the default site
RUN apt-get install -y \
		apache2 \
		perl \
		libcgi-pm-perl \
		libdbi-perl \
		libdbd-mysql-perl \
	&& a2enmod cgid \
	&& a2dissite 000-default \
	&& rm /var/www/html/index.html
	
# Copy custom shipping-challenge site config to container
COPY shipping-challenge.conf /etc/apache2/sites-enabled/shipping-challenge.conf
COPY index.pl db_seed.pl db_update_name.pl basic_footer.css favicon.ico tux_in_box.png /var/www/html/

RUN chmod +x /var/www/html/index.pl \
            /var/www/html/db_seed.pl \
            /var/www/html/db_update_name.pl \
	&& service apache2 restart

# Expose port 80
EXPOSE 80

# run Apache2 in foreground mode
CMD ["apachectl", "-D", "FOREGROUND"]
```
#### Main steps
- Get the Ubuntu 20.04 base image.
- Setup the Timezone ~~(so Apache2 doesn't get mad)~~
- Update everything
- Install [My Stack](#my-stack)
- Copy my Shipping Challenge Application
- Make my Shipping Challenge Application executable
- Expose port 80 for Apache2
- Run Apache2 in foreground mode ~~(so Docker doesn't complain)~~

### DockerHub
My custom Shipping Challenge image is hosted on DockerHub and is accessible in the repo:  
[johanaxel007/shipping-challenge](https://hub.docker.com/repository/docker/johanaxel007/shipping-challenge)

Because my GitHub and DockerHub are linked, whenever I push something to this repository a new Shipping Challenge image is build on DockerHub via Automated Builds.

### Kubernetes
#### Deployment
The deployment downloads the [Shipping Challenge](https://hub.docker.com/repository/docker/johanaxel007/shipping-challenge) image  and creates 3 pods of it. This has also been set up to keep the pods always up-to-date on a restart.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache2
  labels:
    app: apache2
spec:
  replicas: 3 # Number of Instances of Your App
  selector:
    matchLabels:
      app: apache2
  template:
    metadata:
      labels:
        app: apache2
    spec:
      containers:
      - image: johanaxel007/shipping-challenge:latest
        imagePullPolicy: Always # this will always check for a newer image when a pod starts
        name: apache2 # name of the container, only used for you to know what is running
        ports:  
        - containerPort: 80 # this gives the port 80 the name apache2
          name: apache2
```

#### Service
The service gives the Shipping Challenge pods the correct IP and Port.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache2
  labels:
    app: apache2
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 80 # port on the service IP
      targetPort: apache2 # port on the container, can also be a number
  selector:
    app: apache2
```

#### Ingress
Ingress is used to expose the Shipping Challenge Application to the outside world, it also acts as the load balancer to keep things running smooth.
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apache2-ingress
  namespace: default
spec:
  rules:
    - host: shipping-challenge.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: apache2
                port:
                  number: 80
```

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

### Perl Script
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

### Docker Repository
  - https://docs.docker.com/docker-hub/repos/
  - https://docs.docker.com/docker-hub/builds/

### Kubernetes
  - MySQL + Networking setup
    - https://github.com/meyskens/intro-to-k8s/tree/main/wordpress
  - MySQL
    - https://github.com/bitnami/charts/tree/master/bitnami/mysql
  - Ingress File
    - https://kubernetes.io/docs/concepts/services-networking/ingress/
  - Deployment File
    - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

### Portainer
  - https://documentation.portainer.io/v2.0/deploy/linux/
  - https://github.com/portainer/portainer-k8s/blob/master/charts/portainer-beta/README.md