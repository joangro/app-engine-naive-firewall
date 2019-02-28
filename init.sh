#!/bin/bash

PROJECT=$(gcloud config get-value project)


add_role_binding()
{
	# Create Role Binding body request
	RB_BODY="{
  			\"members\": [
  				\"$SINK_SA\"
			],
			\"role\": \"roles/bigquery.dataOwner\"
		}"
	curl -X POST https://cloudresourcemanager.googleapis.com/v1/projects/$PROJECT:setIamPolicy \
		-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
		-d"{
			\"members\": [
				\"serviceAccount:$SINK_SA\"
			],
			\"role\": \"roles/bigquery.dataOwner\"
	
		}"

}

# CREATE LOG SINK IN BIG QUERY FROM APP ENGINE REQUESTS

curl -X POST https://logging.googleapis.com/v2/projects/$PROJECT_ID/sinks?uniqueWriterIdentity=true \
-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
-d"{ 
    \"name\": \"app-engine-firewall-sink\", 
    \"destination\": \"bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/app_engine_firewall_sink\",
    \"filter\": \"appengine.googleapis.com%2Frequest_log\"
}"


# RETREIVE SERVICE ACCOUNT CREATED TO WRITE ON THE SINK

SINK_SA=$(curl https://logging.googleapis.com/v2/projects/$PROJECT/sinks/app-engine-firewall-sink \
-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
2>/dev/null | jq -r '.writerIdentity' | cut -d':' -f 2)

echo $SINK_SA


# check if bigquery.dataOwner role binding exists

if 	[[ ! $(	curl -X POST https://cloudresourcemanager.googleapis.com/v1/projects/$PROJECT:getIamPolicy \
		-H"Authorization: Bearer $(gcloud auth print-access-token)" -H"content-type:application/json" \
		2>/dev/null | jq -r '.bindings[].role' | grep -n 'bigquery.dataOwner') ]]; then

	add_role_binding

else
	echo todo

fi

