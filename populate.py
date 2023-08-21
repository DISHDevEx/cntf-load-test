import subprocess
import random
import time

# Generate random 10-digit number for IMSI
def generate_random_imsi():
    digits = 10
    current_time = int(time.time())
    random_number = current_time * random.randint(1, 10000)
    while len(str(random_number)) < 12:
        random_number = int(str(random_number) + str(random.randint(0, 9)))
    imsi_id = str(random_number)[:digits]
    return imsi_id

# Loop to subscribe 10 UEs
for _ in range(10000):
    imsi_id = generate_random_imsi()
    print(f"Subscribing UE with IMSI: {imsi_id}")

    # Execute the kubectl command to subscribe the UE
    populate_pod = subprocess.run(
        ["kubectl", "-n", "openverso", "get", "pod", "--output=jsonpath={.items..metadata.name}", "-l", "app.kubernetes.io/component=populate"],
        capture_output=True,
        text=True
    )

    if populate_pod.returncode == 0:
        populate_pod_name = populate_pod.stdout.strip()
        subprocess.run(
            ["kubectl", "-n", "openverso", "exec", populate_pod_name, "--", "open5gs-dbctl", "add_ue_with_slice", imsi_id, "465B5CE8B199B49FAA5F0A2EE238A6BC", "E8ED289DEBA952E4283B54E88E6183CA", "internet", "1", imsi_id]
        )

        # Append IMSI_ID to IMSI_IDs.txt for later use
        with open("IMSI_IDs.txt", "a") as file:
            file.write(imsi_id + "\n")
    else:
        print("Failed to get populate pod name")
