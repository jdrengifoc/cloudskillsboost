# Task 1. Enable IAP TCP forwarding in your Google Cloud project
gcloud services enable iap.googleapis.com
# Task 2. Create Linux and Windows Instances
gcloud compute instances create linux-iap --zone=$ZONE --machine-type e2-medium --subnet=default --no-address
gcloud compute instances create windows-iap --zone=$ZONE --machine-type e2-medium --subnet=default --no-address \
    --create-disk auto-delete=yes,boot=yes,device-name=windows-iap,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20230315,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/us-east1-c/diskTypes/pd-balanced
gcloud compute instances create windows-connectivity --zone=$ZONE --machine-type e2-medium \
    --create-disk auto-delete=yes,boot=yes,device-name=windows-connectivity,image=projects/qwiklabs-resources/global/images/iap-desktop-v001,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/us-east1-c/diskTypes/pd-balanced \
    --scopes https://www.googleapis.com/auth/cloud-platform
# Task 3. Configure the required firewall rules for BCE
export PROJECT_ID=$(gcloud config get-value project)
gcloud compute --project=$PROJECT_ID firewall-rules create allow-ingress-from-iap --direction=INGRESS \
    --priority=1000 --network=default --action=ALLOW --rules=tcp:22,tcp:3389 --source-ranges=35.235.240.0/20
