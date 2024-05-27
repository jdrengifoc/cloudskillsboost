#!/bin/bash

# Create global variables.
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-east4
export ZONE=us-east4-b
export BUCKET_NAME=$PROJECT_ID-bucket
export FUNCTION_NAME=memories-thumbnail-creator
export TOPIC_NAME=topic-memories-102
export EMAIL_PREVIOUS_ENGINEER=student-00-e906de5d1937@qwiklabs.net

# Prerrequisites
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Give yourself requirede permissions.
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $PROJECT_ID)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role='roles/pubsub.publisher'

# TASK 1 Create bucket.
gsutil mb -l $REGION gs://$BUCKET_NAME

# TASK 2 Create topic.
gcloud pubsub topics create $TOPIC_NAME

# TASK 3
# Disable and re-enable the Cloud Function API.
gcloud services disable cloudfunctions.googleapis.com
gcloud services enable cloudfunctions.googleapis.com

# Create directory.
mkdir gcf-thumbnail
cd gcf-thumbnail

# Create files.
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/main/gcloud_CFC/skill_badges/06_setup_AppDevEnv/index.js
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/main/gcloud_CFC/skill_badges/06_setup_AppDevEnv/packages.js

# Deploy gcf.
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --region=$REGION \
  --runtime nodejs20 \
  --entry-point=$FUNCTION_NAME \
  --trigger-bucket=$BUCKET_NAME

# Test gcf.
curl -o map.jpg https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/main/gcloud_CFC/skill_badges/06_setup_AppDevEnv/map.jpg
gsutil mv map.jpg gs://$BUCKET_NAME

# Revocque acces to previous engineer.
gcloud projects remove-iam-policy-binding $PROJECT_ID \
  --member="user:$EMAIL_PREVIOUS_ENGINEER" \
  --role="roles/viewer"
