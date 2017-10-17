# New Fiware's Keystone Administrator tools
[![License badge](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Prerequisites
You'll need **jq** and **python-openstackclient** installed so the script can properly work.

### Install JQ:
There are several ways of installing jq, please check: https://stedolan.github.io/jq/

    wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod 755 ./jq
    sudo mv jq /usr/bin
    sudo chown root.root /usr/bin/jq


### Install the latest python-openstackclient
My personal preference is to install it in its own python virtualenv, but this is not stictly required.


    virtualenv os
    source os/bin/activate
    pip instal python-openstackclient

### Remember to create the OS_XX variables before running the Script


    unset OS_TENANT_ID
    unset OS_TENANT_NAME
    
    export OS_REGION_NAME="regionname"
    export OS_USERNAME=adminuser
    export OS_PASSWORD=adminpassword
    export OS_AUTH_URL=http://keystone:5000/v3
    export OS_PROJECT_NAME=admin
    
    export OS_PROJECT_DOMAIN_ID=default
    export OS_USER_DOMAIN_ID=default
    export OS_IDENTITY_API_VERSION=3

Now you can use the script ---


## user_create.sh

    user_create.sh some.email@example.com [community|trial]

The script will get an email as 1st parameter and an optional second parameter which can be *community* or *trial*. 
By default, it will assume the 2nd parameter to be community if it is not present.

The script follows a series of steps:
- Create a new Project for the user. The project name will be "some.mail@example.com cloud" for the above example.
- Create the new user using as name the email, the default project created in the previous step and a random password. It will also add the trial or community fields (xxx_started_at and xxx_duration).
- Assign the role trial or community to the newly created user.
- Assign the user's project to the endpoint group defined for OS_REGION_NAME

Please, run with care.  

## user_community_update.sh 

    user_community_update.sh some.email@example.com [community|trial]

The script will get an email as 1st parameter and an optional second parameter which can be *community* or *trial*. 
By default, it will assume the 2nd parameter to be community if it is not present.

The script checks that the user exists. If it does, it will update its information about community or trial account (duration and started_at will be set to today)
