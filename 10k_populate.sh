#!/bin/bash

generate_imsi() {
    digits=10
    current_time=$(date +%s)
    random_number=$((current_time * (1 + RANDOM % 10000)))
    while [ ${#random_number} -lt 12 ]; do
        random_number="${random_number}$(shuf -i 0-9 -n 1)"
    done
    imsi_id="${random_number:0:digits}"
    echo "$imsi_id"
}

ue_populate() {
    local id="$1"
    echo "command ue_populate running with ${id}"
    populate_pod_name=$(kubectl -n openverso get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

    if [ $? -eq 0 ]; then 
        kubectl -n openverso exec $populate_pod_name -- open5gs-dbctl add_ue_with_slice $id 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
    fi
}

run_helm_commands() {
    local id="$1"
    echo "command helm running with ${id}"

    helm_template_command="helm template -n openverso ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    helm_upgrade_command="helm -n openverso upgrade --install ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    echo "Running helm template command: ${helm_template_command}"
    $helm_template_command

    echo "Running helm upgrade command: ${helm_upgrade_command}"
    $helm_upgrade_command
}

populate() {
    for _ in {1..10}; do
        id=$(generate_imsi)
        ue_populate "$id"
        run_helm_commands "$id"
    done
}

populate
