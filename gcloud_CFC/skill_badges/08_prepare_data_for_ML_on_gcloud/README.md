# Tutorial - [08 Prepare Data for ML APIs on Google Cloud](https://www.cloudskillsboost.google/course_templates/631)

1. Enter the following comands in gcloud CLI with your specific data. For the `API_KEY` go to `apis & services`/`Credential` and click the button `+ CREATE CREDENTIAL`/`API KEY`.
```
export DATASET_NAME=lab_989
export TABLE_NAME=customers_556
export BUCKET_NAME=qwiklabs-gcp-03-0f562536e3f1-marking
export REGION=us-central1
export TASK_3_BUCKET_NAME=gs://qwiklabs-gcp-03-0f562536e3f1-marking/task3-gcs-184.result
export TASK_4_BUCKET_NAME=gs://qwiklabs-gcp-03-0f562536e3f1-marking/task4-cnl-864.result
export API_KEY=AIzaSyBmfb7pMoXTPCSntlGK415A7IJYdtcdVuY
```
2. Copy and paste the following comands in the gcloud CLI. If you want to understand how to do it check [07_build_secure_gcloud_network.sh](https://github.com/jdrengifoc/cloudskillsboost/tree/maing/cloud_CFC/skill_badges/07_build_secure_gcloud_network/07_build_secure_gcloud_network.sh).
```
curl -O https://raw.githubusercontent.com/jdrengifoc/cloudskillsboost/tree/main/gcloud_CFC/skill_badges/07_build_secure_gcloud_network/07_build_secure_gcloud_network.sh
chmod +x 07_build_secure_gcloud_network.sh
./07_build_secure_gcloud_network.sh
```
3. Check the steps and end the lab.

