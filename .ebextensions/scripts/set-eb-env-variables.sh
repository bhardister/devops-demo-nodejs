#!/bin/bash

# Decided NOT to use this script as env vars are app wide and I don't want to be making them per instance 
echo "START set-eb-env-variables script as user: $USER"
instanceId=$(curl -sS http://169.254.169.254/latest/meta-data/instance-id)
echo "instanceId = $instanceId"
ebEnvName=$(aws ec2 describe-instances --instance-ids $instanceId --query='Reservations[].Instances[0].Tags[?Key==`elasticbeanstalk:environment-name`].Value' --output text)
echo "ebEnvName = $ebEnvName"
esHosts=$(aws es list-domain-names | jq '.[] | .[].DomainName' -r)

# load in this environmen'ts beanstalk environment properties
sudo /opt/elasticbeanstalk/bin/get-config environment | python -c "import json,sys; obj=json.load(sys.stdin); f = open('/tmp/eb_env', 'w'); f.write('\n'.join(map(lambda x: 'export ' + x[0] + '=' + x[1], obj.iteritems())))" && source /tmp/eb_env
echo "envrionment = $environment"

for esHost in $esHosts
do
  echo "esHost = $esHost"
  domainArn=$(aws es describe-elasticsearch-domains --domain-names $esHost | jq '.[]|.[].ARN' -r)
  domainEnv=$(aws es list-tags --arn $domainArn | jq '.[]|.[]|select(.Key=="EsEnv")' | jq '.Value' -r)
  echo "  $esHost domainEnv = $domainEnv"
  if [ "$environment" == "$domainEnv" ]; then
     echo "  match found"
     esDomainName="$esHost"
  fi
done

echo "esDomainName = $esDomainName"
aws elasticbeanstalk update-environment --environment-name $ebEnvName --option-settings Namespace=aws:elasticbeanstalk:application:environment,OptionName=esDomainName,Value=$esDomainName
echo "END set-eb-env-variables script"
