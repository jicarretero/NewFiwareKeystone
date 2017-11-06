#!/bin/bash

data="{ \"auth\": {
        \"identity\": {
            \"methods\": [ \"password\" ],
            \"password\": {
                \"user\": {
                    \"name\": \"$OS_USERNAME\",
                    \"domain\": {\"id\":\"default\"},
                    \"password\": \"$OS_PASSWORD\"
                }
            }
        }
    }
}"

tmpfile=$(tempfile)

curl -i http://cloud.lab.fiware.org:4730/v3/auth/tokens -H "Content-Type: application/json" \
  -d  "$data" 2>/dev/null > ${tmpfile}

token=$(awk '/^X-Subject-Token: / {print $2}' ${tmpfile})
tenant_id=$(tail -1 ${tmpfile} | jq -r '.token.project.id')


echo "${tenant_id} ${token}"
rm $tmpfile
