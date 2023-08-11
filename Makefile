create_cluster:
	eksctl create cluster -f cluster.yml

delete_cluster:
	eksctl delete cluster -f cluster.yml

describe_cluster:
	eksctl utils describe-stacks --region=ap-south-1 --cluster=game

aws_identity:
	aws sts get-caller-identity

set_context:
	eksctl utils write-kubeconfig --region=ap-south-1 --cluster=game --set-kubeconfig-context=true

enable_iam_sa_provider:
	 eksctl utils associate-iam-oidc-provider --region=ap-south-1 --cluster= game --approve

create_cluster_role:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

create_iam_policy:
	curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
	aws iam create-policy \
     --policy-name AWSLoadBalancerControllerIAMPolicy \
     --policy-document file://iam_policy.json

create_service_account:
	eksctl create iamserviceaccount \
	  --region=ap-south-1 \
      --cluster=game \
      --namespace=kube-system \
      --name=aws-load-balancer-controller \
      --attach-policy-arn=arn:aws:iam::{your_IAM_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
      --override-existing-serviceaccounts \
      --approve

deploy_ingress_controller:
	helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  	  -n kube-system \
  	  --set clusterName=game \
  	  --set serviceAccount.create=false \
  	  --set serviceAccount.name=aws-load-balancer-controller 


deploy_ingress_controller:
	kubectl get deployment -n kube-system aws-load-balancer-controller



deploy_application:
	kustomize build ./k8s | kubectl apply -f -

delete_application:
	kustomize build ./k8s | kubectl delete -f -

