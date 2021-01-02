# 2APPAI1 - Linux Webservices - Shipping Challenge 2020

- **Name**: Van Gestel Axel
- **Class**: 2 APPAI 1
- **Studentnr**: r0784084
- **DockerHub**: [johanaxel007/shipping-challenge](https://hub.docker.com/repository/docker/johanaxel007/shipping-challenge)

## Stack
- Webserver: Apache2
- Database: MySQL
- Script Language: Perl
- (Extra: Portainer) <-- Not done

## Installation
- Installed on Minikube on Windows 10 with the Ingress plugin enabled.
    - `minikube start`
    - `minikube addons enable ingress`
- Install Helm 3 and add Bitnami Helm Repo.
    - `helm repo add bitnami https://charts.bitnami.com/bitnami`
- Setup MySQL using Helm (see "install mysql.txt").
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