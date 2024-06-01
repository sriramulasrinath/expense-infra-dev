#!/bin/bash
component=$1
environment=$2
dnf install ansible -y
pip3.9 install botocore boto3 # to connect aws
ansible-pull -i localhost, -U https://github.com/sriramulasrinath/expense-ansible-roles-tf.git main.yml -e component=$component -e env=$environment