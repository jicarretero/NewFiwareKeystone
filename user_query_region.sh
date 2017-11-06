#!/bin/bash

user=$1
[ -z $user ] && (echo "necesita como parametro el usuario" ; exit 1)

project_id=$(openstack user show ${user} | awk 'BEGIN {done=0}
     /cloud_project_id/ {id=$4 ; done=1}
     /default_project_id/ {dpid=$4}
     END {if (done==1) {print id} else {print dpid}}'
)
token=$(openstack token issue | awk '/ id / {print $4}')

curl http://cloud.lab.fiware.org:4730/v3/OS-EP-FILTER/projects/${project_id}/endpoint_groups \
     -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" 2>/dev/null | jq -r .endpoint_groups[].filters.region_id
