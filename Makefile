.DEFAULT_GOAL := all
SHELL:=/bin/bash
REPOSITORY=chassidemo

pokemon: .guard-REPOSITORY
	@echo "---> building pokemon raspberry pi application container"
	docker build -t $(REPOSITORY)/pokemon:latest -f pokemon.Dockerfile examples/pokemon/

publish: .guard-APPLICATION
	@echo "---> publishing $(APPLICATION) raspberry pi application"
	docker push $(REPOSITORY)/$(APPLICATION):latest

.guard-%:
	@ if [ "${${*}}" = "" ]; then \
		printf "\033[0;31m[!] Parameter '$*' is not set\nYou can set it with:\n  make $*=<value> target\033[0m\n\n"; \
		make help; \
		exit 1; \
	fi