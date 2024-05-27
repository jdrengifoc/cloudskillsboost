# Tutorial - [07 Build a Secure Google Cloud Network](https://www.cloudskillsboost.google/paths/36/course_templates/654)

To obtain the skill badge you must do at least the following labs (the order doesn't matter).

## [Securing Virtual Machines using BeyondCorp Enterprise (BCE)](https://www.cloudskillsboost.google/paths/36/course_templates/654/labs/464656)
1. Enter the following comands in gcloud CLI with your specific data. The zone two must be 
```
export ZONE=us-east4-b
```
2. Copy and paste the following comands in the gcloud CLI. If you want to understand how to do it check [07_securing_VM_using_BCE.sh](https://github.com/jdrengifoc/cloudskillsboost/tree/maing/cloud_CFC/skill_badges/07_build_secure_gcloud_network/07_securing_VM_using_BCE.sh).
```
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/tree/main/gcloud_CFC/skill_badges/07_build_secure_gcloud_network/07_create_internal_load_balancer.sh
chmod +x 07_securing_VM_using_BCE.sh
./07_securing_VM_using_BCE.sh
```
3. Do **Step 4** manually following the instructions.

4. Check all the steps (Step 5 and 6 aren't necessary to make) and finish the lab.

## [Create an Internal Load Balancer](https://www.cloudskillsboost.google/paths/36/course_templates/654/labs/464660)
1. Enter the following comands in gcloud CLI with your specific data. The zone two must be 
```
export REGION=us-west1
export ZONE=us-west1-c
```

2. Copy and paste the following comands in the gcloud CLI. If you want to understand how to do it check [07_create_internal_load_balancer.sh](https://github.com/jdrengifoc/cloudskillsboost/tree/maing/cloud_CFC/skill_badges/07_build_secure_gcloud_network/07_create_internal_load_balancer.sh).
```
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/tree/main/gcloud_CFC/skill_badges/07_build_secure_gcloud_network/07_create_internal_load_balancer.sh
chmod +x 07_create_internal_load_balancer.sh
./07_create_internal_load_balancer.sh
```
3. Check the steps, answer *Server Location* and *Server Hostname*to the question *Which of these fields identify the location of the backend?* and end the lab.

## [Build a Secure Google Network Challenge lab.](https://www.cloudskillsboost.google/paths/36/course_templates/654/labs/464661)

1. Enter the following comands in gcloud CLI with your specific data.
```
export SSH_IAP_NETWORK_TAG=accept-ssh-iap-ingress-ql-953
export SSH_INTERNAL_NETWORK_TAG=accept-ssh-internal-ingress-ql-953
export HTTP_NETWORK_TAG=accept-http-ingress-ql-953
export ZONE=us-east4-b
```
2. Copy and paste the following comands in the gcloud CLI. If you want to understand how to do it check [07_build_secure_gcloud_network.sh](https://github.com/jdrengifoc/cloudskillsboost/tree/maing/cloud_CFC/skill_badges/07_build_secure_gcloud_network/07_build_secure_gcloud_network.sh).
```
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/tree/main/gcloud_CFC/skill_badges/07_build_secure_gcloud_network/07_build_secure_gcloud_network.sh
chmod +x 07_build_secure_gcloud_network.sh
./07_build_secure_gcloud_network.sh
```
3. Check the steps and end the lab.