.SECONDEXPANSION:

##################################################################################
# BUILD VARIABLES
##################################################################################

VERSION 									= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH									= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE 									= $(shell date +%FT%T%z)

##################################################################################
# GLOBAL SECRETS
##################################################################################

#RANCHER_PASSWORD 			= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w rancherBootstrapPassword | awk '{print $$2}')
#HARBOR_PASSWORD 			= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w harborAdminPassword | awk '{print $$2}')
#VSPHERE_PASSWORD 			= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w vsphere_password | awk '{print $$2}')
#RANCHER_RKE_VSPHERE_PASSWORD 		= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w rancher_rke_vsphere_password | awk '{print $$2}')

# Azure Secrets
#TENANT_ID 				= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w azure_tenant_id | awk '{print $$2}')
#SUBSCRIPTION_ID 			= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w azure_subscription_id | awk '{print $$2}')
#CLIENT_ID 				= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w azure_client_id | awk '{print $$2}')
#CLIENT_SECRET 				= $(shell helm secrets view config/${ENVIRONMENT}/secrets.yaml | grep -w azure_client_secret | awk '{print $$2}')

##################################################################################
# RANCHER MCM CLUSTER - VSPHERE VARIABLES - ONLY MODIFY IF OVERRIDE NEEDED
##################################################################################

VSPHERE_SERVER				= "rgs-vcenter-1.lab"
VSPHERE_USERNAME			= "administrator"
VSPHERE_PASSWORD			= "Welcome2theLab!"
VSPHERE_INSECURE			= true
VSPHERE_DATACENTER			= RGS Datacenter
VSPHERE_CLUSTER				= RGS Cluster
VSPHERE_DATASTORE			= ESXi1-NVME
VSPHERE_VM_FOLDER			= 
VSPHERE_NETWORK				= VM Network
VSPHERE_TEMPLATE			= rocks-rocky8-ag
VM_COUNT                  		= 1
VM_NAME                  		= jumpbox
VM_HOSTNAME              		= jumpbox
VM_DOMAIN				= .lab
VM_IPV4_ADDR_PREFIX			= 10.7.2.10
VM_IPV4_NETMASK				= 24
VM_IPV4_GATEWAY				= 10.7.2.1

VM_CPUS 				= 4
VM_MEMORY				= 8192
#VM_MEMORY_RESERVATION   		= 28672
VM_DISK_SIZE 				= 60
#VM_NIC_INTERFACE			= ens160
VM_FIRMWARE        			= efi
#VM_EFI_SEC_BOOT_ENABLED 		= false


##################################################################################
# RKE2 RANCHER MCM CLUSTER CONFIGS - ALL PROVIDERS
##################################################################################

RKE2_VERSION				= v1.21.9+rke2r1
RANCHER_VERSION				= v2.6.3
LONGHORN_VERSION			= v1.2.3

##################################################################################
# HELM VARIABLES
##################################################################################

HELM_KUBE_VIP_VERSION			= 0.2.1
HELM_KUBE_VIP_CLOUD_PROVIDER_VERSION	= 0.4.2
HELM_CERT_MANAGER_VERSION		= v1.5.1
HELM_INGRESS_NGINX_VERSION		= 4.0.16
HELM_LONGHORN_VERSION			= ${LONGHORN_VERSION}
HELM_HARBOR_VERSION			= 1.8.1
HELM_RANCHER_VERSION			= $(shell echo ${RANCHER_VERSION} | cut -d v -f2)

# Ingress domains for Apps

RANCHER_INGRESS_DNS			= rancher.${WILDCARD_INGRESS_DNS}
HARBOR_INGRESS_DNS			= harbor.${WILDCARD_INGRESS_DNS}
NOTARY_INGRESS_DNS			= harbor.${WILDCARD_INGRESS_DNS}

# kube-vip and kube-vip-controller vars

HELM_vip_address			= ${RKE2_API_VIP}
HELM_vip_interface			= ${VM_NIC_INTERFACE}
HELM_vip_leaderelection			= true
HELM_svc_lb_destinationCIDR		= ${WILDCARD_INGRESS_VIP}/32

##################################################################################
# RANCHER DOWNSTREAM CLUSTER CONFIGS - ALL PROVIDERS
##################################################################################

RANCHER_MCM_ENVIRONMENT			= ${ENVIRONMENT}
RANCHER_RKE_CLUSTER			= ${ENVIRONMENT}-openspace

RANCHER_RKE_CNI_PROVIDER		= calico

RANCHER_RKE_VM_DNS_SUFFIX_LIST    	= ${VM_DNS_SUFFIX_LIST}
RANCHER_RKE_VM_DNS_SERVER_LIST    	= ${VM_DNS_SERVER_LIST}

# RANCHER_RKE_K8S_VERSION		= v1.20.14-rancher2-1
RANCHER_RKE_K8S_VERSION		 	= v1.21.7-rancher1-1

RANCHER_RKE_MASTER_POOL_COUNT  	 	= 3
RANCHER_RKE_WORKER_POOL_COUNT  	 	= 2

# vsphere specific

RANCHER_RKE_VSPHERE_SERVER		= ${VSPHERE_SERVER}
RANCHER_RKE_VSPHERE_USERNAME         	= ${VSPHERE_USERNAME}
RANCHER_RKE_VSPHERE_INSECURE		= ${VSPHERE_INSECURE}

RANCHER_RKE_VSPHERE_DATACENTER   	= ${VSPHERE_DATACENTER}
RANCHER_RKE_VSPHERE_CLUSTER         	= ${VSPHERE_CLUSTER}
RANCHER_RKE_VSPHERE_DATASTORE       	= ${VSPHERE_DATASTORE}
RANCHER_RKE_VSPHERE_NETWORK         	= ${VSPHERE_NETWORK}
RANCHER_RKE_VSPHERE_TEMPLATE        	= ${VSPHERE_TEMPLATE}

RANCHER_RKE_VSPHERE_TEMPLATE_FOLDER	= ${VSPHERE_TEMPLATE_FOLDER}
RANCHER_RKE_VSPHERE_VM_FOLDER		= ${VSPHERE_VM_FOLDER}

RANCHER_RKE_DEFAULT_CPU_COUNT	   	= 2
RANCHER_RKE_DEFAULT_MEMORY 		= 8192
RANCHER_RKE_DEFAULT_DISK_SIZE	 	= 125000

RANCHER_RKE_VSPHERE_RESOUCE_POOL 	= Resources

RANCHER_API_URL				= https://${RANCHER_INGRESS_DNS}

##################################################################################
# GLOBAL
##################################################################################

KUBECONFIG_CONTEXT			= ${ENVIRONMENT}
KUBECONFIG_CONTEXT_PATH			= $(ENV_BUILD_CACHE)/${KUBECONFIG_CONTEXT}.cfg

SSH_USERNAME				= centos
SSH_KEY_FILE_NAME			= rancher_ssh_key
SSH_KEY_FILE_PATH			= $(ENV_BUILD_CACHE)

##################################################################################
# TERRAFORM VARIABLES - ONLY MODIFY IF OVERRIDE NEEDED
##################################################################################

# Logging

###TF_LOG				= INFO

## Global Terraform Configs

TF_VAR_ssh_username			= ${SSH_USERNAME}
TF_VAR_key_file				= ${SSH_KEY_FILE_NAME}
TF_VAR_key_file_path			= ${SSH_KEY_FILE_PATH}
TF_VAR_rancher_mcm_environment		= ${ENVIRONMENT}

TF_VAR_wildcard_ingress_ip 		= ${WILDCARD_INGRESS_VIP}
TF_VAR_rancher_ingress_domain 		= ${RANCHER_INGRESS_DNS}
TF_VAR_harbor_ingress_domain		= ${HARBOR_INGRESS_DNS}

# Credentials

TF_VAR_vsphere_server 			= ${VSPHERE_SERVER}
TF_VAR_vsphere_username 		= ${VSPHERE_USERNAME}
TF_VAR_vsphere_password 		= ${VSPHERE_PASSWORD}
TF_VAR_vsphere_insecure 		= ${VSPHERE_INSECURE}

# vSphere Settings

TF_VAR_vsphere_datacenter 		= ${VSPHERE_DATACENTER}
TF_VAR_vsphere_cluster    		= ${VSPHERE_CLUSTER}
TF_VAR_vsphere_datastore  		= ${VSPHERE_DATASTORE}
TF_VAR_vsphere_vm_folder  		= ${VSPHERE_VM_FOLDER}
TF_VAR_vsphere_network    		= ${VSPHERE_NETWORK}
TF_VAR_vsphere_template   		= ${VSPHERE_TEMPLATE}

# Rancher HA Production-like VM Settings. 8 vPCU, 28 GB RAM,250 GB DISK

# based on count, 0-2 will be appended to VM name and IP
TF_VAR_vm_count                		= ${VM_COUNT}
TF_VAR_vm_name                 		= ${VM_NAME}
TF_VAR_vm_hostname             		= ${VM_HOSTNAME}
TF_VAR_vm_cpus                 		= ${VM_CPUS}
TF_VAR_vm_memory               		= ${VM_MEMORY}
TF_VAR_vm_memory_reservation   		= ${VM_MEMORY_RESERVATION}
TF_VAR_vm_disk_size            		= ${VM_DISK_SIZE}
TF_VAR_vm_firmware             		= ${VM_FIRMWARE}
TF_VAR_vm_efi_secure_boot_enabled	= ${VM_EFI_SEC_BOOT_ENABLED}
TF_VAR_vm_domain                	= ${VM_DNS_SUBDOMAIN}
TF_VAR_vm_ipv4_address         		= ${VM_IPV4_ADDR_PREFIX}
TF_VAR_vm_ipv4_netmask         		= ${VM_IPV4_NETMASK}
TF_VAR_vm_ipv4_gateway          	= ${VM_IPV4_GATEWAY}
TF_VAR_vm_dns_suffix_list       	= ${VM_DNS_SUFFIX_LIST}
TF_VAR_vm_dns_server_list       	= ${VM_DNS_SERVER_LIST}
TF_VAR_vm_nic_interface			= ${VM_NIC_INTERFACE}

## Rancher RKE Downstream Cluster Configs - vSphere VM settings

# Credentials

TF_VAR_rancher_api_url			= ${RANCHER_API_URL}
#TF_VAR_rancher_token_access_key	= ${RANCHER_TOKEN_ACCESS_KEY}
#TF_VAR_rancher_token_secret_key 	= ${RANCHER_TOKEN_SECRET_KEY}
TF_VAR_rancher_admin_password		= ${RANCHER_PASSWORD}

TF_VAR_rancher_rke_vsphere_server	= ${RANCHER_RKE_VSPHERE_SERVER}
TF_VAR_rancher_rke_vsphere_username    	= ${RANCHER_RKE_VSPHERE_USERNAME}
TF_VAR_rancher_rke_vsphere_password    	= ${RANCHER_RKE_VSPHERE_PASSWORD}
TF_VAR_rancher_rke_vsphere_insecure	= ${RANCHER_RKE_VSPHERE_INSECURE}

# vSphere RKE Node Template Configs

TF_VAR_rancher_rke_vsphere_datacenter  	= ${RANCHER_RKE_VSPHERE_DATACENTER}
TF_VAR_rancher_rke_vsphere_cluster     	= ${RANCHER_RKE_VSPHERE_CLUSTER}
TF_VAR_rancher_rke_vsphere_datastore   	= ${RANCHER_RKE_VSPHERE_DATASTORE}
TF_VAR_rancher_rke_vsphere_network     	= ${RANCHER_RKE_VSPHERE_NETWORK}
TF_VAR_rancher_rke_vsphere_template     = ${RANCHER_RKE_VSPHERE_TEMPLATE}
TF_VAR_rancher_rke_vsphere_template_folder 	= ${RANCHER_RKE_VSPHERE_TEMPLATE_FOLDER}
TF_VAR_rancher_rke_vsphere_pool        	= ${RANCHER_RKE_VSPHERE_RESOUCE_POOL}
TF_VAR_rancher_rke_vsphere_vm_folder    = ${RANCHER_RKE_VSPHERE_VM_FOLDER}
TF_VAR_rancher_rke_cpucount		= ${RANCHER_RKE_DEFAULT_CPU_COUNT}
TF_VAR_rancher_rke_memory 		= ${RANCHER_RKE_DEFAULT_MEMORY}
TF_VAR_rancher_rke_disksize 		= ${RANCHER_RKE_DEFAULT_DISK_SIZE}

TF_VAR_rancher_rke_vm_dns_suffix_list	= ${RANCHER_RKE_VM_DNS_SUFFIX_LIST}
TF_VAR_rancher_rke_vm_dns_server_list	= ${RANCHER_RKE_VM_DNS_SERVER_LIST}

# vSphere RKE Cluster Template Configs

TF_VAR_rancher_rke_k8s_version		= ${RANCHER_RKE_K8S_VERSION}
TF_VAR_rancher_rke_delaysec		= 120

# vSphere RKE Cluster Instance Configs

TF_VAR_rancher_rke_cluster     		= ${RANCHER_RKE_CLUSTER}
TF_VAR_rancher_rke_master_pool_count 	= ${RANCHER_RKE_MASTER_POOL_COUNT}
TF_VAR_rancher_rke_worker_pool_count 	= ${RANCHER_RKE_WORKER_POOL_COUNT}
TF_VAR_rancher_rke_cni_provider		= ${RANCHER_RKE_CNI_PROVIDER}


## Set Downstream Cluster Defaults to Upstream Cluster Configs.  Override at environment specific config

RANCHER_RKE_TENANT_ID 			= ${TENANT_ID}
RANCHER_RKE_SUBSCRIPTION_ID 		= ${SUBSCRIPTION_ID}
RANCHER_RKE_CLIENT_ID 			= ${CLIENT_ID}
RANCHER_RKE_CLIENT_SECRET 		= ${CLIENT_SECRET}

RANCHER_RKE_LOCATION 			= ${LOCATION}
RANCHER_RKE_RESOURCE_GROUP_NAME 	= ${RESOURCE_GROUP_NAME}
RANCHER_RKE_VNET_RESOURCE_GROUP_NAME 	= ${VNET_RESOURCE_GROUP_NAME}
RANCHER_RKE_VNET_NAME 			= ${VNET_NAME}
RANCHER_RKE_SUBNET_NAME 		= ${SUBNET_NAME}
RANCHER_RKE_NETWORK_SECURITY_GROUP_NAME	= ${NETWORK_SECURITY_GROUP_NAME}

RANCHER_RKE_OS_DISK_SIZE_GB 		= ${OS_DISK_SIZE_GB}

# AZURE TERRAFORM VARIABLES - RANCHER_MCM CLUSTER CLUSTERS

TF_VAR_tenant_id 			= ${TENANT_ID}
TF_VAR_subscription_id 			= ${SUBSCRIPTION_ID}
TF_VAR_client_id 			= ${CLIENT_ID}
TF_VAR_client_secret 			= ${CLIENT_SECRET}
TF_VAR_location 			= ${LOCATION}
TF_VAR_resource_group_name 		= ${RESOURCE_GROUP_NAME}
TF_VAR_vnet_resource_group_name 	= ${VNET_RESOURCE_GROUP_NAME}
TF_VAR_vnet 				= ${VNET_NAME}
TF_VAR_subnet 				= ${SUBNET_NAME}
TF_VAR_security_group 			= ${NETWORK_SECURITY_GROUP_NAME}
TF_VAR_os_disk_size_gb 			= ${OS_DISK_SIZE_GB}

# AZURE TERRAFORM VARIABLES - DOWNSTREAM CLUSTERS

TF_VAR_rancher_rke_tenant_id 		= ${RANCHER_RKE_TENANT_ID}
TF_VAR_rancher_rke_subscription_id 	= ${RANCHER_RKE_SUBSCRIPTION_ID}
TF_VAR_rancher_rke_client_id 		= ${RANCHER_RKE_CLIENT_ID}
TF_VAR_rancher_rke_client_secret 	= ${RANCHER_RKE_CLIENT_SECRET}
TF_VAR_rancher_rke_location 		= ${RANCHER_RKE_LOCATION}
TF_VAR_rancher_rke_resource_group_name 	= ${RANCHER_RKE_RESOURCE_GROUP_NAME}
TF_VAR_rancher_rke_vnet_resource_group_name	= ${RANCHER_RKE_VNET_RESOURCE_GROUP_NAME}
TF_VAR_rancher_rke_vnet			= ${RANCHER_RKE_VNET_NAME}
TF_VAR_rancher_rke_subnet 		= ${RANCHER_RKE_SUBNET_NAME}
TF_VAR_rancher_rke_security_group 	= ${RANCHER_RKE_NETWORK_SECURITY_GROUP_NAME}
TF_VAR_rancher_rke_security_group 	= ${RANCHER_RKE_OS_DISK_SIZE_GB}
