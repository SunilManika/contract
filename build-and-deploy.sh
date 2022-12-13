#!/bin/bash

read -p "Dockerhub Username: " DOCKERHUB_NAME
read -s -p "Dockerhub Password: " DOCKERHUB_PASS

[ -z "$DOCKERHUB_NAME" ] && echo "Missing required Dockerhub Username"  && exit 1
[ -z "$DOCKERHUB_PASS" ] && echo "Missing required Dockerhub Password"  && exit 1

ibmcloud ce project create -n "ContractCE"
id=$(ibmcloud ce proj current | grep "Context:" | awk '{print $2}')
ibmcloud ce registry create -n "${DOCKERHUB_NAME}-dockerhub" -u $DOCKERHUB_NAME -p $DOCKERHUB_PASS -s https://index.docker.io/v1/


# Hotel
ibmcloud ce build create -n contract-v1-build -i ${DOCKERHUB_NAME}/contract-v1:latest --src https://github.com/shancs09/contract --rs "${DOCKERHUB_NAME}-dockerhub" --cdr src --sz small
ibmcloud ce buildrun submit -b contract-v1-build -n contract-v1-buildrun -w
ibmcloud ce app create -n contract-ce -i ${DOCKERHUB_NAME}/contract-v1:latest --cl -p 9101 --min 1 --cpu 0.25 -m 0.5G -e LOG_LEVEL=info
