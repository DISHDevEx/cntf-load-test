# #!/usr/bin/env bash

# commands to install kubectl and helm on the gnb-ues pod
install_dependencies () {
    apt update
    apt install -y curl
    curl --version
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    kubectl version --client
    curl -LO https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz
    tar -zxvf helm-v3.7.0-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
    helm version
}

# generate a random IMSI_ID number
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

# populate open5gs with the random IMSI_ID number
ue_populate() {
    local id="$1"
    echo "command ue_populate running with ${id}"
    
    # Assuming you are already inside the pod
    open5gs-dbctl add_ue_with_slice "$id" 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA internet 1 111111
}

# create 3000 UEs 
test() {
    for _ in {1..3000}; do
        id=$(generate_imsi)
        ue_populate "$id"
    done
}

install_dependencies
test


