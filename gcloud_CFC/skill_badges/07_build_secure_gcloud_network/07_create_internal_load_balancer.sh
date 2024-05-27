#!/bin/bash

# Define ZONE2 as a zone in $REGION that isn't $ZONE.
# List all available zones in the region.
echo "Available zones in region $REGION:"
ZONES=$(gcloud compute zones list --filter="region:($REGION)" --format="value(name)")
echo "$ZONES"

# Find a different zone in the same region
for zone in $ZONES; do
  if [ "$zone" != "$ZONE" ]; then
    export ZONE2=$zone
    break
  fi
done

# Output the selected zones
echo "ZONE: $ZONE"
echo "ZONE2: $ZONE2"

# Task 1. Configure HTTP and health check firewall rules
# Create a firewall rule to allow HTTP traffic to the backends from the Load Balancer and the internet (to install Apache on the backends).
gcloud compute firewall-rules create app-allow-http --network my-internal-app --action allow --direction INGRESS \
    --target-tags lb-backend --source-ranges 0.0.0.0/0 --rules tcp:80
# Create the health check firewall rules.
gcloud compute firewall-rules create app-allow-health-check --network default --action allow --direction INGRESS \
    --target-tags lb-backend --source-ranges 130.211.0.0/22,35.191.0.0/16 --rules tcp

# Task 2. Configure instance templates and create instance groups.
# Configure first instance template.
gcloud compute instance-templates create instance-template-1 --machine-type=e2-medium --region $REGION --tags=lb-backend \
    --network=my-internal-app --subnet=subnet-a --metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh
# Configure second instance template.
gcloud compute instance-templates create instance-template-2 --machine-type=e2-medium --region $REGION --tags=lb-backend \
    --network=my-internal-app --subnet=subnet-b --metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh
# Create first manage instance group with autoscaling.
gcloud compute instance-groups managed create instance-group-1 --base-instance-name=instance-group-1 --template=instance-template-1 \
    --zone=$ZONE --size=1
gcloud compute instance-groups managed set-autoscaling instance-group-1 --zone=$ZONE \
    --min-num-replicas=1 --max-num-replicas=5 --target-cpu-utilization=0.8 --cool-down-period=45
# Create second manage instance group with autoscaling.
gcloud compute instance-groups managed create instance-group-2 --base-instance-name=instance-group-1 --template=instance-template-1 \
    --zone=$ZONE2 --size=1
gcloud compute instance-groups managed set-autoscaling instance-group-2 --zone=$ZONE2 --min-num-replicas=1 --max-num-replicas=5 \
    --target-cpu-utilization=0.8 --cool-down-period=45
# Create a utility VM instance.
gcloud compute instances create utility-vm --zone=$ZONE --machine-type=e2-micro --image-family=debian-10 --image-project=debian-cloud \
    --boot-disk-size=10GB --boot-disk-type=pd-standard --network=my-internal-app --subnet=subnet-a --private-network-ip=10.10.20.50

# Task 3. Configure the Internal Load Balancer
# Create a health check for load balancing.
gcloud compute health-checks create tcp my-ilb-health-check \
--description="Subscribe To CloudHustlers" \
--check-interval=5s \
--timeout=5s \
--unhealthy-threshold=2 \
--healthy-threshold=2 \
--port=80 \
--proxy-header=NONE

# Obtain an access token.
TOKEN=$(gcloud auth application-default print-access-token)

# Create a JSON configuration file for the backend service.
cat > 1.json <<EOF
{
    "backends": [
      {
        "balancingMode": "CONNECTION",
        "group": "projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instanceGroups/instance-group-1"
      },
      {
        "balancingMode": "CONNECTION",
        "group": "projects/$DEVSHELL_PROJECT_ID/zones/$ZONE2/instanceGroups/instance-group-2"
      }
    ],
    "connectionDraining": {
      "drainingTimeoutSec": 300
    },
    "description": "",
    "healthChecks": [
      "projects/$DEVSHELL_PROJECT_ID/global/healthChecks/my-ilb-health-check"
    ],
    "loadBalancingScheme": "INTERNAL",
    "logConfig": {
      "enable": false
    },
    "name": "my-ilb",
    "network": "projects/$DEVSHELL_PROJECT_ID/global/networks/my-internal-app",
    "protocol": "TCP",
    "region": "projects/$DEVSHELL_PROJECT_ID/regions/$REGION",
    "sessionAffinity": "NONE"
  }
EOF

# Create a JSON configuration file for the forwarding rule.
cat > 2.json <<EOF
{
   "IPAddress": "10.10.30.5",
   "loadBalancingScheme": "INTERNAL",
   "allowGlobalAccess": false,
   "description": "SUBSCRIBE TO CLOUDHUSTLER",
   "ipVersion": "IPV4",
   "backendService": "projects/$DEVSHELL_PROJECT_ID/regions/$REGION/backendServices/my-ilb",
   "IPProtocol": "TCP",
   "networkTier": "PREMIUM",
   "name": "my-ilb-forwarding-rule",
   "ports": [
     "80"
   ],
   "region": "projects/$DEVSHELL_PROJECT_ID/regions/$REGION",
   "subnetwork": "projects/$DEVSHELL_PROJECT_ID/regions/$REGION/subnetworks/subnet-b"
 }
EOF

# Create the backend service with the JSON configuration.
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d  @1.json \
  "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/backendServices"

# Wait for 20 seconds.
sleep 20

# Create the forwarding rule with the JSON configuration.
curl -X POST -H "Content-Type: application/json" \
 -H "Authorization: Bearer $TOKEN" \
 -d @2.json \
 "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/forwardingRules"