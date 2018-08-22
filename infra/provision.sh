#!/bin/bash
set -e
while getopts "r:e:" opt; do
   case $opt in
    r) runcmd="$OPTARG"
      ;;
    e) envname="$OPTARG"    
      ;;
    \?) echo "Invalid option -$OPTARG" >&2
       ;;
  esac
done

 

if [ -z ${runcmd} ] || [ -z ${envname} ] ; then
    printf "\n"
    printf "Please provide environment and terraform command \n\n"
    printf "valid environment values are int, stage, PROD \n"
    printf "\n"

elif [ "${runcmd}" != "init" ] && [  "${runcmd}" != "plan" ] && [  "${runcmd}" != "apply" ]   && [  "${runcmd}" != "validate" ]  && [  "${runcmd}" != "destroy" ]; then
    printf "\n"
    printf "!!! invalid terraform command entry !!! \n"
    printf "Valid terraform command to run this script is:  init,plan,apply or destroy \n"
else
  

    export datevar=$(date +%Y%m%d-%H-%M)
    sed -i  's/BITBUCKET_CREDENTIALS/'"${BITBUCKET_CREDENTIALS}"'/g' *.tf

    if [ ${runcmd} == "init" ];then
       rm -rf .terraform/
       yes yes |  TF_WORKSPACE=${envname} terraform ${runcmd}
    elif [ ${runcmd} == "destroy" ];then   

      TF_WORKSPACE=${envname} terraform ${runcmd} -var-file="variables/$envname.tfvars"   -var "hosted_zone_name=${HOSTED_ZONE_NAME}" -force 
     elif [ ${runcmd} == "apply" ];then
       TF_WORKSPACE=${envname} terraform ${runcmd} -var-file="variables/$envname.tfvars"    -var "hosted_zone_name=${HOSTED_ZONE_NAME}"  -auto-approve
       export api_dns_name=$( TF_WORKSPACE=${envname} terraform output api_dns_name)
       export ui_dns_name=$( TF_WORKSPACE=${envname} terraform output ui_dns_name)
       echo $api_dns_name
       echo $ui_dns_name
    else
       TF_WORKSPACE=${envname} terraform ${runcmd} -var-file="variables/$envname.tfvars"    -var "hosted_zone_name=${HOSTED_ZONE_NAME}"
    fi

fi
