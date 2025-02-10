#building the docker Image
docker build -t pwc-microservice ./Microservices

#starting the service on Docker
docker run -p 5000:5000 pwc-microservice


cd terraform
terraform init
terraform apply -auto-approve

update requirements file with : Werkzeug==2.2.2

terraform output kube_config > ~/.kube/config
export KUBECONFIG=~/.kube/config

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get pods
kubectl get services

