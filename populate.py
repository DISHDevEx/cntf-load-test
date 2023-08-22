# import subprocess
# import random
# import time

# # Generate random 10-digit number for IMSI to populate
# def generate_random_imsi():
#     digits = 10
#     current_time = int(time.time())
#     random_number = current_time * random.randint(1, 10000)
#     while len(str(random_number)) < 12:
#         random_number = int(str(random_number) + str(random.randint(0, 9)))
#     imsi_id = str(random_number)[:digits]
#     return imsi_id

# # Loop to subscribe 10 UEs
# for _ in range(10):
#     imsi_id = generate_random_imsi()
#     print(f"Subscribing UE with IMSI: {imsi_id}")

#     # Execute the kubectl command to subscribe the UE
#     populate_pod = subprocess.run(
#         ["kubectl", "-n", "openverso", "get", "pod", "--output=jsonpath={.items..metadata.name}", "-l", "app.kubernetes.io/component=populate"],
#         capture_output=True,
#         text=True
#     )

#     if populate_pod.returncode == 0:
#         populate_pod_name = populate_pod.stdout.strip()
#         subprocess.run(
#             ["kubectl", "-n", "openverso", "exec", populate_pod_name, "--", "open5gs-dbctl", "add_ue_with_slice", imsi_id, "465B5CE8B199B49FAA5F0A2EE238A6BC", "E8ED289DEBA952E4283B54E88E6183CA", "internet", "1", imsi_id]
#         )

#         imsi_ids_filename = "imsi_ids.txt"
#         try:
#             with open(imsi_ids_filename, "a") as imsi_file:
#                 imsi_file.write(imsi_id + "\n")
#         except Exception as e:
#             print("Error writing to imsi_ids.txt:", e)
            
#     else:
#         print("Failed to get populate pod name")

import subprocess
import random
import time

def generate_random_imsi():
    digits = 10
    current_time = int(time.time())
    random_number = current_time * random.randint(1, 10000)
    while len(str(random_number)) < 12:
        random_number = int(str(random_number) + str(random.randint(0, 9)))
    imsi_id = str(random_number)[:digits]
    return imsi_id

def create_ue_with_ueransim(imsi_id):
    subprocess.run(["ueransim", "cli", "gen-key", imsi_id])
    subprocess.run(["ueransim", "cli", "gen-cer", imsi_id])
    subprocess.run(["ueransim", "cli", "gen-kea", imsi_id])

def subscribe_ue_to_network(imsi_id):
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

        imsi_ids_filename = "imsi_ids.txt"
        try:
            with open(imsi_ids_filename, "a") as imsi_file:
                imsi_file.write(imsi_id + "\n")
        except Exception as e:
            print("Error writing to imsi_ids.txt:", e)
    else:
        print("Failed to get populate pod name")

# Loop to create and subscribe 10 UEs
for _ in range(10):
    imsi_id = generate_random_imsi()
    print(f"Creating and Subscribing UE with IMSI: {imsi_id}")

    create_ue_with_ueransim(imsi_id)
    subscribe_ue_to_network(imsi_id)

