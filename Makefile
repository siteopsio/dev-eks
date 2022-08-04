.EXPORT_ALL_VARIABLES:
.ONESHELL:
.PHONY: 
SHELL := /bin/bash
TERRAFORM_VERSION := 1.0.11
DIR := $(shell pwd)
TOPDIR := $(shell git rev-parse --show-toplevel)
#TF_VARS = project.tfvars

ifndef TOPDIR
 	TOPDIR := .
endif

#include $(TOPDIR)/common/_makefile
include Makefile.env
#include project.tfvars

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

stateinit:  ## Initializes the bucket and dynamodb for state
	chmod 755 build_state_config.py
	./build_state_config.py tfstate
	@cd tfstate  ;terraform fmt ; terraform init

stateplan: stateinit  ## Shows the plan
	@cd tfstate  ;terraform plan -input=false -refresh=true 

stateapply: stateinit  ## Inits the plan
	@cd tfstate  ;terraform apply -input=true -refresh=true 

stateclean:  ## destroy and clean the state WARNING!! This will nuke everythig!!!
	terraform destroy ; rm -rf .terraform *.tfstate*  backend.tf providers.tf variables.tf versions.tf main.tf
