# #!/usr/bin/env bash

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
    populate_pod_name=$(kubectl -n cntf-tests get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

    if [ $? -eq 0 ]; then 
        kubectl -n cntf-tests exec $populate_pod_name -- open5gs-dbctl add_ue_with_slice $id 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
    fi
}

run_helm_commands() {
    local id="$1"
    echo "command helm running with ${id}"

    helm_template_command="helm template -n cntf-tests ueransim-load-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    helm_upgrade_command="helm -n cntf-tests upgrade --install ueransim-load-test openverso/ueransim-ues \
        --set ues.initialMSISDN=${id} \
        --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

    echo "Running helm template command: ${helm_template_command}"
    $helm_template_command

    echo "Running helm upgrade command: ${helm_upgrade_command}"
    $helm_upgrade_command
}

test() {
    for _ in {1..1000}; do
        id=$(generate_imsi)
        ue_populate "$id"
        run_helm_commands "$id"
    done
}

test


# !usr/bin/env bash

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

# run_helm_commands() {
#     # imsi_id=$1

#     echo "command helm running with ${imsi_id}"

#     helm_template_command="helm template -n openverso ueransim-load-test openverso/ueransim-ues \
#         --set ues.initialMSISDN=${imsi_id} \
#         --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

#     helm_upgrade_command="helm -n openverso upgrade --install ueransim-load-test openverso/ueransim-ues \
#         --set ues.initialMSISDN=${imsi_id} \
#         --values https://raw.githubusercontent.com/DISHDevEx/napp/main/napp/open5gs_values/gnb_ues_values.yaml"

#     echo "Running helm template command: ${helm_template_command}"
#     $helm_template_command

#     echo "Running helm upgrade command: ${helm_upgrade_command}"
#     $helm_upgrade_command
# }

# ue_populate() {
# #   imsi_id=$1
#   echo "command ue_populate running with ${imsi_id}"
#   populate_pod_name=$(kubectl -n openverso get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

#   if [ $? -eq 0 ]; then 
#     kubectl -n openverso exec $populate_pod_name -- open5gs-dbctl add_ue_with_slice $imsi_id 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
#   fi
# }

# for _ in {1..10}; do
#     # imsi_id=$(generate_random_imsi)
#     generate_random_imsi
#     ue_populate 
#     echo "Subscribing UE with IMSI: ${imsi_id}"
#     run_helm_commands 
#     echo "Allocating IMSI: ${imsi_id} to UE with helm"
# done
