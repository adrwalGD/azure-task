#!/bin/bash

RG_NAME=grid-rg-task
LOCATION=westeurope
VNET_NAME=grid-vnet
SUBNET_NAME=grid-subnet
NSG_NAME=grid-nsg
PUB_IP_NAME=grid-pip
VM_NIC_NAME=vm-grid-nic
VM_NAME=grid-vm
VNET_NET="10.0.0.0/16"
SUBNET_NET="10.0.1.0/24"
VM_PRIV_IP="10.0.1.4"
ACR_NAME=acrgridtask
ACR_SKU=basic


az group create \
    --name "$RG_NAME" \
    --location "$LOCATION"

az network vnet create \
    --resource-group "$RG_NAME" \
    --name "$VNET_NAME" \
    --address-prefixes "$VNET_NET"

az network nsg create \
    --resource-group "$RG_NAME" \
    --name "$NSG_NAME"

az network nsg rule create \
    --resource-group "$RG_NAME" \
    --nsg-name "$NSG_NAME" \
    --name allow-SSH \
    --access allow \
    --protocol tcp \
    --priority 1000 \
    --destination-port-ranges 22

az network nsg rule create \
    --resource-group "$RG_NAME" \
    --nsg-name "$NSG_NAME" \
    --name allow-HTTP \
    --access allow \
    --protocol tcp \
    --priority 1001 \
    --destination-port-ranges 80

az network vnet subnet create \
    --resource-group "$RG_NAME" \
    --vnet-name "$VNET_NAME" \
    --name "$SUBNET_NAME" \
    --address-prefixes "$SUBNET_NET" \
    --network-security-group "$NSG_NAME"

az network public-ip create \
    --resource-group "$RG_NAME" \
    --name "$PUB_IP_NAME"

az network nic create \
    --resource-group "$RG_NAME" \
    --name "$VM_NIC_NAME" \
    --vnet-name "$VNET_NAME" \
    --subnet "$SUBNET_NAME" \
    --public-ip-address "$PUB_IP_NAME" \
    --network-security-group "$NSG_NAME" \
    --private-ip-address "$VM_PRIV_IP"

az vm create \
    --resource-group "$RG_NAME" \
    --name "$VM_NAME" \
    --image Ubuntu2404 \
    --nics "$VM_NIC_NAME" \
    --admin-username azureuser \
    --ssh-key-values "./ssh-keys"

az acr create \
    -g "$RG_NAME" \
    -n "$ACR_NAME" \
    --sku "$ACR_SKU"
