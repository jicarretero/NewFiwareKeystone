#!/bin/bash

user_name=$1
role=${2:-community}
email=${user_name}
region_id=${OS_REGION_NAME}


[ -z $email ] && exit 1

[ $role != "trial" -a $role != "community" ] && (echo "Role is ${role} and should be trial or community" >&2 && exit 1)

[ ${role} == "community" ] && duration=270
[ ${role} == "trial" ] && duration=15

echo $duration

password=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)

project_name="$user_name cloud"

echo "New User: " $email
echo "Password: " $password

tempfile=$(tempfile)
date=$(date +%Y-%m-%d)

# Check if the user exists. If it does, nothing is created
user_id=$(openstack user show "${user_name}" 2>/dev/null)
not_exists_project=$?
[ $not_exists_project -eq 0 ] && (echo "User exists: ${user_id}" >&2 && exit 1)

# Check if the project exists. If it does, nothing is created
project_id=$(openstack project show "${project_name}" 2>/dev/null | awk '/\| id / {print $4}')
not_exists_project=$?
[ $not_exists_project -eq 0 ] && (echo "Project exists: ${project_id}" >&2 && exit 1)

# Create the project
project_id=$(openstack project create "${project_name}" | awk '/\| id / {print $4}')
echo "Project created: ${project_id}"

# Get a new token
token=$(openstack token issue | awk '/\| id / {print $4}')

# Create the user with some metadata 
d="{
    \"user\": {
        \"default_project_id\": \"${project_id}\",
        \"enabled\": true,
        \"name\": \"${user_name}\",
        \"password\": \"${password}\",
        \"${role}_started_at\": \"${date}\",
        \"${role}_duration\": \"${duration}\"
    }
}"

curl -H "X-Auth-token: ${token}" -H "content-type: application/json" ${OS_AUTH_URL}/users -d "${d}" -X POST 2>/dev/null

# Add the new project and user to community or trial role
openstack role add --project ${project_id} --user ${user_name} ${role}

## Add the user to the Spain2 Group:
## endpoint_group 1d2.... belongs to Spain2
endpoint_group=$(curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/ -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" 2>/dev/null | jq -r ".endpoint_groups[] | select(.filters.region_id==\"${region_id}\") | .id")

curl ${OS_AUTH_URL}/OS-EP-FILTER/endpoint_groups/${endpoint_group}/projects/${project_id}  -X PUT -H "X-AUTH-TOKEN: ${token}" -H "Content-Type: application/json"

