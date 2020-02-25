#!/bin/bash

for filename in ${TEST_HOME_DIR}/conf/helmfile.d/*.yaml; do
    deployment_name=$(grep "\- name: " ${filename} | grep -m1 -v "\- name: \"stable\"" | awk '{print $3}' | sed 's/^\"\(.\+\)\"$/\1/')
    retries=3
    for ((i=0; i<retries; i++)); do
        ${TEST_HOME_DIR}/helmfile_linux_amd64 --selector name=${deployment_name} sync
        [[ $? -eq 0 ]] && break
        echo "Something went wrong while deploying ${deployment_name}. Retrying in 30 seconds."
        helm delete ${deployment_name} --purge
        sleep 30
    done
done