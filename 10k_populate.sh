#!/bin/bash

# generate_random_imsi() {
#     digits=10
#     current_time=$(date +%s)
#     random_number=$((current_time * (1 + RANDOM % 10000)))
#     while [ ${#random_number} -lt 12 ]; do
#         random_number="${random_number}$(shuf -i 0-9 -n 1)"
#     done
#     imsi_id="${random_number:0:digits}"
#     echo $imsi_id
# }

generate_random_imsi() {
    digits=10
    current_time=$(date +%s)
    random_number=$((current_time * (1 + RANDOM % 10000)))
    while [ ${#random_number} -lt 12 ]; do
        random_number="${random_number}$(shuf -i 0-9 -n 1)"
    done
    imsi_id="${random_number:0:digits}"
    echo $imsi_id
}

run_helm_commands() {
    imsi_id=$1

    helm_template_command="helm template -n openverso ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    helm_upgrade_command="helm -n openverso upgrade --install ueransim-10k-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${imsi_id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    echo "Running helm template command: ${helm_template_command}"
    $helm_template_command

    echo "Running helm upgrade command: ${helm_upgrade_command}"
    $helm_upgrade_command
}

for _ in {1..10}; do
    imsi_id=$(generate_random_imsi)
    echo "Subscribing UE with IMSI: ${imsi_id}"

    run_helm_commands $imsi_id

    imsi_ids_filename="imsi_ids.txt"
    if [ -w "$imsi_ids_filename" ]; then
        echo $imsi_id >> $imsi_ids_filename
    else
        echo "Error writing to imsi_ids.txt"
    fi
done

