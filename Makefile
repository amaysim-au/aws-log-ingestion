SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

COMPOSE_RUN_SERVERLESS = docker compose run --rm serverless
AWS_PROFILE ?= ama-nonprod-admin
ENVFILE ?= .env.template

envfile:
	cp -f $(ENVFILE) .env

shell:
	$(COMPOSE_RUN_SERVERLESS) bash

deploy: envfile
	. awsume $(AWS_PROFILE) && $(COMPOSE_RUN_SERVERLESS) make _deploy

remove:
	. awsume $(AWS_PROFILE) && $(COMPOSE_RUN_SERVERLESS) make _remove


_deploy: _apk
	sls plugin install -n serverless-python-requirements
	sls deploy

_remove:
	sls remove

_apk:
	apk --no-cache add poetry

.PHONY: shell deploy _venv _deploy _apk _remove

