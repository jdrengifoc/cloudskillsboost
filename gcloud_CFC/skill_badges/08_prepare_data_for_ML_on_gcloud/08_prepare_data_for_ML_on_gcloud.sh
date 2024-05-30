#!/bin/bash
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
export SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Function to check and assign a role if not already assigned
assign_role_if_needed() {
  local role=$1
  if ! gcloud projects get-iam-policy "$PROJECT_ID" --flatten="bindings[].members" --format="csv(bindings.role,bindings.members)" | grep -q "${role},serviceAccount:${SERVICE_ACCOUNT}"; then
    echo "Assigning role ${role} to ${SERVICE_ACCOUNT}"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:${SERVICE_ACCOUNT}" \
      --role="${role}"
  else
    echo "Role ${role} is already assigned to ${SERVICE_ACCOUNT}"
  fi
}

# Check and assign the 'editor' and 'storage.admin' role
assign_role_if_needed "roles/editor"
assign_role_if_needed "roles/storage.admin"
assign_role_if_needed "roles/compute.instanceAdmin"

# Task 1. Run a simple Dataflow job.
# Create a BigQuery dataset and table.
bq mk $DATASET_NAME
bq mk --table $DATASET_NAME.$TABLE_NAME
# Create bucket.
gsutil mb gs://$BUCKET_NAME
# Run Dataflow job.
gcloud dataflow jobs run dataflow-batch-job \
  --gcs-location gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery \
  --region $REGION \
  --staging-location gs://$DEVSHELL_PROJECT_ID-marking/temp \
  --worker-machine-type e2-standard-2 \
  --parameters inputFilePattern=gs://cloud-training/gsp323/lab.csv,JSONPath=gs://cloud-training/gsp323/lab.schema,outputTable=$DEVSHELL_PROJECT_ID:$DATASET_NAME.$TABLE_NAME,bigQueryLoadingTemporaryDirectory=gs://$DEVSHELL_PROJECT_ID-marking/bigquery_temp,javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,javascriptTextTransformFunctionName=transform


# Task 2.  Run a simple Dataproc job
# Create cluster from console.
gcloud config set dataproc/region $REGION
gcloud compute networks subnets update default \
    --region $REGION \
    --enable-private-ip-google-access
gcloud dataproc clusters create my-cluster \
  --region $REGION \
  --master-machine-type e2-standard-2 \
  --master-boot-disk-type pd-balanced \
  --master-boot-disk-size 50 \
  --num-workers 2 \
  --worker-machine-type e2-standard-2 \
  --worker-boot-disk-type pd-balanced \
  --worker-boot-disk-size 50 \
  --image-version 2.2-debian12 \
  --project $PROJECT_ID

# Log into cluster node.
gcloud compute ssh --project=$PROJECT_ID --zone=us-central1-c my-cluster
hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt
exit

# Submit job.
gcloud dataproc jobs submit spark \
  --cluster=my-cluster \
  --region=$REGION \
  --class=org.apache.spark.examples.SparkPageRank \
  --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
  --max-failures-per-hour=1 \
  -- /data.txt

# Task 3. Use the Google Cloud Speech-to-Text API
# Enable API.
gcloud services enable speech.googleapis.com

# Create a Service Account and Key.
gcloud iam service-accounts create my-speech-to-text-sa --display-name "Speech to sext service account."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:my-speech-to-text-sa@$PROJECT_ID.iam.gserviceaccount.com"\
  --role "roles/editor"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-speech-to-text-sa@$PROJECT_ID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/key.json"

gcloud auth activate-service-account my-speech-to-text-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --key-file=$GOOGLE_APPLICATION_CREDENTIALS

cat > request.json <<EOF 
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-training/gsp323/task3.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > response.json
gsutil cp response.json $TASK_3_BUCKET_NAME

# Task 4. Use the Cloud Natural Language API
# Create an API key
gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-natlang-sa@${PROJECT_ID}.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/key.json"

gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
gsutil cp result.json $TASK_4_BUCKET_NAME
    
