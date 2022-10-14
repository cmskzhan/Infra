#!/bin/bash
echo "make sure new environment no existing ec2 instance"
aws configure --profile temp1
# create new key pair
rm -f tttt.pem
aws ec2 create-key-pair --key-name att1t3 --key-type rsa --key-format pem --profile temp1 | jq -r ".KeyMaterial" > tttt.pem 
chmod 400 tttt.pem
#create new security group
aws ec2 create-security-group --description "cli created 2ndary" --group-name "tt1" --profile temp1
aws ec2 authorize-security-group-ingress --group-name "tt1" --protocol tcp --port 22 --cidr 0.0.0.0/0 --profile temp1
aws ec2 authorize-security-group-ingress --group-name "tt1" --protocol tcp --port 443 --cidr 0.0.0.0/0 --profile temp1
aws ec2 authorize-security-group-ingress --group-name "tt1" --protocol tcp --port 80 --cidr 0.0.0.0/0 --profile temp1
# TODO might also need to check if outbound is allowed

# create new instance
aws ec2 run-instances --image-id ami-08e2d37b6a0129927 --count 1 --instance-type t2.micro --key-name att1t3 --security-groups tt1 --profile temp1
sleep 10

state=`aws ec2 describe-instances --profile temp1 | jq -r ".Reservations"[]."Instances"[]."State"."Code"`
while [ $state -ne 16 ]
do
    echo "waiting for instance to be running, current state is $state"
    sleep 10
    state=`aws ec2 describe-instances --profile temp1 | jq -r ".Reservations"[]."Instances"[]."State"."Code"`
done

ip_address=`aws ec2 describe-instances --profile temp1 | jq -r ".Reservations"[]."Instances"[]."PublicIpAddress"`
echo "ssh ec2-user@$ip_address -i tttt.pem"
