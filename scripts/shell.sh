function connect_to_aws() {
    serviceName=$1
    shift
    env=$1
    shift
    nodeType=$1
    shift
    color=$1

    ipAddr=$(get_aws_ec2_ip "$serviceName" "$env" "$nodeType" "$color")
    echo "$ipAddr"
}

function get_aws_ec2_ip() {
    local serviceName=$1
    shift
    local env=$1
    shift
    local nodeType=$1
    shift
    local color=$1
    shift

    local pid="ts"
    if [ "${serviceName}" = "jasper" ]; then
        pid="ts00329"
    elif [ "${serviceName}" = "dyncalc" ]; then
        pid="ts00851"
    fi

    local instanceName="${pid}-${env}-${serviceName}"
    local clusterName="${pid}-${env}-${serviceName}-emr-flink"

    if [[ "x$color" != "x" ]] ; then
      instanceName="${instanceName}-${color}"
      clusterName="${clusterName}-${color}"
    fi

    if [ "$nodeType" = "web" ]; then
        ipAddr=$(aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" "Name=tag:Name,Values=${instanceName}-web" | jq -r ".Reservations[] | .Instances[] | .PrivateIpAddress")
    elif [ "$nodeType" = "master" ]; then
        clusterId=$(aws emr list-clusters --active | jq -r ".Clusters[] | select(.Name == \"${clusterName}\") | .Id")
        ipAddr=$(aws emr list-instances --cluster-id $clusterId --instance-group-types MASTER | jq -r ".Instances[0].PrivateIpAddress")
    fi
    echo "$ipAddr"
}

function connect_aws() {
    if [ "$#" -ne 3 ]; then
        echo "Illegal number of parameters"
        echo "Sample: connect jasper stg web"
        exit(1)
    fi

    local serviceName=$1
    shift
    local env=$1
    shift
    local nodeType=$1
    shift

    keyname="${serviceName}_${env}"
    username="ec2-user"
    if [ "$nodeType" = "master" ]; then
        username="hadoop"
    fi

    ipAddr=$(get_aws_ec2_ip $serviceName $env $nodeType)
    echo "$serviceName $env $nodeType ip address is $ipAddr"
    ssh -i ~/.ssh/$keyname -D 8157 -o StrictHostKeyChecking=no ${username}@${ipAddr} "$@"
}

function connect_to_jasper_master() {
    ipAddr=`connect_to_aws jasper stg master`
    echo "$env master node ip address is $ipAddr"
    cmd="ssh -i ~/.ssh/jasper_nonprod -o StrictHostKeyChecking=no -A hadoop@${ipAddr} -D 8157 " 

    echo $cmd
    eval $cmd
}

function connect_to_jasper_web() {
    ipAddr=`connect_to_aws jasper stg web`
    echo "$env master node ip address is $ipAddr"
    cmd="ssh -i ~/.ssh/jasper_nonprod -o StrictHostKeyChecking=no -A ec2-user@${ipAddr}" 

    echo $cmd
    eval $cmd
}

function connect_to_dyncalc_master() {
    env=$1
    shift
    color=$1
    shift 
    ipAddr=`connect_to_aws dyncalc qa master green`
    echo "$env master node ip address is $ipAddr"
    cmd="ssh -i ~/.ssh/dyncalc_nonprod -o StrictHostKeyChecking=no -A hadoop@${ipAddr} -D 8157 " 

    echo $cmd
    eval $cmd
}


### AWS authentication
### need: pip3 install keyring
### need: $python3 -m keyring set aws-sts djia@morningstar.com
alias awsauth_profile_stg_rw="export AWS_PROFILE=datasvc-non-prod-operator; export AWS_REGION=us-east-1"
alias awsauth_profile_prod_ro="export AWS_PROFILE=datasvc-prod-readonly"
alias awsauth_stg="awsauth stg"
alias awsauth_prod="awsauth prod"
function awsauth() {
    env=$1
    echo "env =" $env
    if [ "$env" = "stg" ]; then
        arn="arn:aws:iam::187914334366:role/mstar-datasvc-non-prod-operator"
        profile="datasvc-non-prod-operator"
    elif [ "$env" = "prod" ]; then
        arn="arn:aws:iam::062740692535:role/mstar-datasvc-prod-readonly"
        profile="datasvc-prod-readonly"
    else
        echo "Error: unknown environment"
        exit(1)
    fi 

    python3 ~/Repos/amazon_adfs/aws-sts-forms-v2.py --username djia --region us-east-1 --profile saml --rolearn "$arn"
    python3 ~/Repos/amazon_adfs/aws-sts-forms-v2.py --username djia --region us-east-1 --profile default --rolearn "$arn"
    python3 ~/Repos/amazon_adfs/aws-sts-forms-v2.py --username djia --region us-east-1 --profile "$profile" --rolearn "$arn"
}


alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfr="terraform refresh"
alias tfw="terraform workspace"
alias rawsstg="crontab -l; sed -i 's/^rolename=.*/rolename=0/' /Users/djia/Repos/amazon_adfs/aws-sts-forms-v2.py; /Users/djia/Repos/amazon_adfs/aws-sts-forms-v2.py"
alias rawsprod="crontab -l; sed -i 's/^rolename=.*/rolename=1/' /Users/djia/Repos/amazon_adfs/aws-sts-forms-v2.py; /Users/djia/Repos/amazon_adfs/aws-sts-forms-v2.py"
alias redisstg="redis-cli -h port-bkdn-stats.tnaw5t.ng.0001.use1.cache.amazonaws.com"
alias redisprod="redis-cli -h port-bkdn-stats.0e152p.ng.0001.use1.cache.amazonaws.com"
alias fofstg="curl 'http://api-data-stg.morningstar.com/dataapi/v2/portfolios/12345/holdings?source=cloud' -H 'Accept: application/json,application/vnd.morningstar.dataapiv2; version=2.27.0' -H 'ApiKey: 7' -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Postman-Token: d7b05433-793e-4c1e-a4ed-da66bec7a266' -H 'X-API-ProductId: Direct' -H 'X-API-UserId: 7827c168-2107-4efb-b990-a80d5954d323'"
alias fofprod="curl 'http://api-data.morningstar.com/dataapi/v2/portfolios/12345/holdings?source=cloud' -H 'Accept: application/json,application/vnd.morningstar.dataapiv2; version=2.27.0' -H 'ApiKey: 7' -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Postman-Token: bdff1904-7ca6-4988-ad9b-2b0560e650fd' -H 'X-API-ProductId: Direct' -H 'X-API-UserId: 57bf0e66-bcf8-4996-9fbd-ebfbe2c5961c'"
alias foflocal="curl 'http://localhost:8080/portfolios/12345/holdings?source=cloud' -H 'Accept: application/json,application/vnd.morningstar.dataapiv2; version=2.27.0' -H 'ApiKey: 7' -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Postman-Token: 86a36e04-3834-43a4-9380-1d674e4f6972' -H 'X-API-ProductId: Direct' -H 'X-API-UserId: 12345'"

# autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^E^E" edit-command-line
