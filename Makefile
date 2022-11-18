.DEFAULT_GOAL := help
SHELL:=/bin/bash
APPLICATION?=pokemon
DOCKER_REPOSITORY?=chassidemo

export PROJECT_ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build-pokemon: ## Build Pokemon showcase docker container
	@echo "---> building pokemon raspberry pi application container"
	docker build -t $(DOCKER_REPOSITORY)/pokemon:latest -f pokemon.Dockerfile examples/pokemon/

publish-pokemon: build-pokemon ## Publish Pokemon showcase application to docker registry
	@echo "---> publishing $(APPLICATION) raspberry pi application"
	docker push $(DOCKER_REPOSITORY)/$(APPLICATION):latest

package-pokemon: ## Generate Pokemon debian artifacts
	@echo "---> generating debian artifacts with gradle"
	${PROJECT_ROOT}/gradlew buildDeb

publishdeb-pokemon: package-pokemon ## Publish Pokemon debs to our debian repository
	@echo "---> publishing debs to debian repository"
	${PROJECT_ROOT}/scripts/devops.sh --publish

help: ## Shows the help
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(shell echo "$(MAKEFILE_LIST)" | tr " " "\n" | sort -r | tr "\n" " ") \
		| sed 's/Makefile[a-zA-Z\.]*://' | sed 's/\.\.\///' | sed 's/.*\///' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ''
