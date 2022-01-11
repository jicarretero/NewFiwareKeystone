#!/bin/bash

project_name=$1
[ -z "$project_name" ] && echo "necesita como parametro el proyecto" && exit 1

# token=$(openstack token issue | awk '/ id / {print $4}')
token=$(openstack token issue -f value -c id)

project_id=$(openstack project show -f value -c id "$project_name")

curl ${OS_AUTH_URL}/OS-EP-FILTER/projects/${project_id}/endpoint_groups \
     -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" 2>/dev/null | jq -r ".endpoint_groups[].filters.region_id"
