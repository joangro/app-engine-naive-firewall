#!/bin/bash

PROJECT=$(gcloud config get-value project)

curl -X POST https://logging.googleapis.com/v2/projects/$PROJECT_ID/sinks?uniqueWriterIdentity=true \
-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
-d"{ 
    \"name\": \"app-engine-firewall-sink\", 
    \"destination\": \"bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/app_engine_firewall_sink\",
    \"filter\": \"appengine.googleapis.com%2Frequest_log\"
}"

SINK_SA=$(curl https://logging.googleapis.com/v2/projects/$PROJECT/sinks/app-engine-firewall-sink \
-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
2>/dev/null | jq -r '.writerIdentity' | cut -d':' -f 2)

echo $SINK_SA

# check if bigquery.dataOwner exists

curl -X POST https://cloudresourcemanager.googleapis.com/v1/projects/wave16-joan:getIamPolicy \
-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
2>/dev/null | jq -r '.bindings[].role' | grep -n 'bigquery.dataOwner'


