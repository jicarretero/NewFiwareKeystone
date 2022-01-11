#!/bin/bash

project_id=$1
[ -z $project_id ] && echo "necesita como parametro el usuario" && exit 1
region_id=$2
[ -z $region_id ] && echo "Necesita region como parametro" && exit 1

token=$(openstack token issue | awk '/ id / {print $4}')

endpoint_group=$(curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/ -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" 2>/dev/null | jq -r ".endpoint_groups[] | select(.filters.region_id==\"${region_id}\") | .id")

curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/${endpoint_group}/projects/${project_id}  -X PUT -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json"
