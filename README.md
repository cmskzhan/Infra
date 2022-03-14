# Infra
Prepare cloud server and AWS

## AWS CLI
update aws cli ID and KEY <br>
create keypair and download pem <br>
aws cloudformation deploy --template-file /path_to_template/template.json --stack-name my-new-stack <br>
aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress"
