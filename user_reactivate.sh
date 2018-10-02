#!/bin/bash

user_name=$1
role=${2:-community}
email=${user_name}
region_id=${OS_REGION_NAME}


[ -z $email ] && exit 1

[ $role != "trial" -a $role != "community" ] && (echo "Role is ${role} and should be trial or community" >&2 && exit 1)

[ ${role} == "community" ] && duration=270
[ ${role} == "trial" ] && duration=15

date=$(date +%Y-%m-%d)

# Check if the user exists. If it does, nothing is created
user_id=$(openstack user show -f value -c id ${email} 2>/dev/null)
not_exists_project=$?

echo $user_id
echo $not_exists_project

if [ $not_exists_project -eq 1 ]; then
	echo "User NOT exists: ${user_name}"
	exit 1
fi

openstack user set --enable ${email}

# Get a new token
token=$(openstack token issue | awk '/\| id / {print $4}')

# Create the user with some metadata 
d="{
    \"user\": {
        \"${role}_started_at\": \"${date}\",
        \"${role}_duration\": \"${duration}\"
    }
}"
curl -H "X-Auth-Token: ${token}" -H "Content-Type: application/json" ${OS_AUTH_URL}/users/${user_id} -X PATCH -d "$d" 2>/dev/null

cloud_project_id=$(openstack  user show -f value -c cloud_project_id ${user_name})

echo

#if [ ! -z $cloud_project_id ]; then
#openstack role add --user ${user_id} --domain default community
#openstack role remove --user ${user_id} --domain default trial
#fi
