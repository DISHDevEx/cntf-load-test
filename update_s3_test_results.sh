#!usr/bin/env bash

POPULATE_POD=$(kubectl -n openverso get pod --output=jsonpath={.items..metadata.name} -l app.kubernetes.io/component=populate)

update_local_test_data () {
   kubectl cp -n openverso $POPULATE_POD:/time_to_populate_database.txt ./time_to_populate_database.txt # update local file with the time it takes to add a new IMSI_ID to the database
}

# this script updates the objects in the s3 bucket "cntf-open5gs-coralogix-test-results" with any changes made to their corresponding local files. 
udpate_s3() {
   aws s3 cp ./time_to_populate_database.txt s3://cntf-open5gs-test-results/time_to_populate_database.txt  # update s3 with the time it takes to add a new IMSI_ID to the database
}

update_local_test_data
udpate_s3
