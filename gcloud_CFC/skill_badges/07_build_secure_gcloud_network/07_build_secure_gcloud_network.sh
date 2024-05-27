#!/bin/bash

# Create global variables.
export PROJECT_ID=$(gcloud config get-value project)
export STUDENT_EMAIL=$(gcloud config get-value account)

# Give you permission to see the VM instances (not necessary.)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$STUDENT_EMAIL" \
    --role="roles/compute.viewer"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$STUDENT_EMAIL" \
    --role="roles/compute.admin"


# Check the firewall rules. Remove the overly permissive rules.
gcloud compute firewall-rules delete open-access
# Navigate to Compute Engine in the Cloud console and identify the bastion host. The instance should be stopped. Start the instance.
gcloud compute instances start bastion --zone=$ZONE
# Create a firewall rule that allows SSH (tcp/22) from the IAP service and add network tag on bastion.
gcloud compute firewall-rules create allow-external-ssh-traffic --allow=tcp:22 --source-ranges 35.235.240.0/20 --target-tags $SSH_IAP_NETWORK_TAG --network acme-vpc
gcloud compute instances add-tags bastion --tags=$SSH_IAP_NETWORK_TAG --zone=$ZONE
# Create a firewall rule that allows traffic on HTTP (tcp/80) to any address and add network tag on juice-shop.
gcloud compute firewall-rules create allow-http-traffic --allow=tcp:80 --source-ranges 0.0.0.0/0 --target-tags $HTTP_NETWORK_TAG --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$HTTP_NETWORK_TAG --zone=$ZONE
# Create a firewall rule that allows traffic on SSH (tcp/22) from acme-mgmt-subnet.
gcloud compute firewall-rules create allow-internal-ssh-traffic --allow=tcp:22 --source-ranges 192.168.10.0/24 --target-tags $SSH_INTERNAL_NETWORK_TAG --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$SSH_INTERNAL_NETWORK_TAG --zone=$ZONE

gcloud compute ssh bastion --zone=$ZONE

gcloud compute ssh juice-shop --zone=$ZONE --internal-ip
gcloud compute ssh juice-shop --internal-ip

