#!/bin/bash

user=$1
[ -z $user ] && echo "necesita como parametro el usuario" && exit 1
region_id=$2
[ -z $region_id ] && echo "Necesita region como parametro" && exit 1

project_id=$(openstack user show ${user} | awk 'BEGIN {done=0}
     /cloud_project_id/ {id=$4 ; done=1}
     /default_project_id/ {dpid=$4}
     END {if (done==1) {print id} else {print dpid}}'
)

token=$(openstack token issue | awk '/ id / {print $4}')

endpoint_group=$(curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/ -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" 2>/dev/null | jq -r ".endpoint_groups[] | select(.filters.region_id==\"${region_id}\") | .id")

curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/${endpoint_group}/projects/${project_id}  -X PUT -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json"

