# Infra
Prepare cloud server and AWS

## AWS CLI
update aws cli ID and KEY <br>
create keypair and download pem <br>
aws cloudformation deploy --template-file /path_to_template/template.json --stack-name my-new-stack <br>
aws cloudformation deploy --template-file f.yaml --stack-name tt2 --parameter-overrides VpcId=vpc-0fc407f59dbf8def6 <br>
aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress"

## VAIO
### install wifi driver on ubuntu 22.04
sudo apt-get install --reinstall bcmwl-kernel-source
