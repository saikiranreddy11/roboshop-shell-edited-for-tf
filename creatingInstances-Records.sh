#!/bin/bash

image=ami-03265a0778a880afb
security_grp=sg-07486e05b46c9943d
subnet=subnet-0dd54bd754c61211a
services=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
Instancetype=""
domainname=saikiransudhireddy.com
hostedzone=Z05570443S15P72O43ST7
for i in "${services[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" ]];
    then 
        Instancetype="t3.micro"
    else
        Instancetype="t2.micro"
    fi
    IP_address=$(aws ec2 run-instances --image-id $image  --instance-type $Instancetype --security-group-ids $security_grp --subnet-id $subnet --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r ".Instances[0].PrivateIpAddress")
    echo "created the $i instance with private IP : $IP_address"

    aws route53 change-resource-record-sets --hosted-zone-id $hostedzone --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "'$i.$domainname'",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP_address'"
                        }
                    ]
                }
            }
        ]
    }'

done