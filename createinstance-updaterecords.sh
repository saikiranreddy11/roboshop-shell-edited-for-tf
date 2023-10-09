#!/bin/bash

image=ami-03265a0778a880afb
security_grp=sg-05ee15da692a6148c
subnet=subnet-0dd54bd754c61211a
#services=("mongodb" "mysql" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
services=$@
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
    echo "created the instance with private IP : $IP_address"

    # aws route53 change-resource-record-sets --hosted-zone-id $hostedzone --change-batch '{
    #     "Changes": [
    #         {
    #             "Action": "CREATE",
    #             "ResourceRecordSet": {
    #                 "Name": "'$i.$domainname'",
    #                 "Type": "A",
    #                 "TTL": 300,
    #                 "ResourceRecords": [
    #                     {
    #                         "Value": "'$IP_address'"
    #                     }
    #                 ]
    #             }
    #         }
    #     ]
    # }'

   #!/bin/bash

# Define your variables
# EXISTING_DOMAIN_NAME="example.com"    # Name of the existing DNS record
# NEW_DOMAIN_NAME="new.example.com"     # Name of the new DNS record
# NEW_IP_ADDRESS="123.456.789.123"     # New IP address to set

# Check if the existing DNS record exists
aws route53 list-resource-record-sets \
    --hosted-zone-id $hostedzone \
    --query "ResourceRecordSets[?Name == '$i.$domainname']" > /dev/null

# $? will contain the exit code of the previous command
if [ $? -eq 0 ]; then
    # The existing DNS record exists, update it
    echo "Updating existing DNS record..."
    aws route53 change-resource-record-sets \
        --hosted-zone-id $hostedzone \
        --change-batch '{
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$i.$domainname.'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP_address'"
                            }
                        ]
                    }
                }
            ]
        }'
else
    # The existing DNS record does not exist, create it
    echo "Creating a new DNS record..."
    aws route53 change-resource-record-sets \
        --hosted-zone-id $hostedzone \
        --change-batch '{
            "Changes": [
                {
                    "Action": "CREATE",
                    "ResourceRecordSet": {
                        "Name": "'$i.$domainname.'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP_address'"
                            }
                        ]
                    }
                }
            ]
        }'
fi

# # Check if the EC2 instance exists, and create it if it doesn't
# INSTANCE_ID=$(aws ec2 describe-instances \
#     --filters "Name=tag:Name,Values=my-instance" \
#     --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null)

# if [ -z "$INSTANCE_ID" ]; then
#     echo "Creating a new EC2 instance..."
#     # Replace with your EC2 instance creation command here
#     # Example: aws ec2 run-instances ...
# else
#     echo "EC2 instance already exists."
# fis


done