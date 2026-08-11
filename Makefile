
.PHONY: start-nix-shell update-flakes update-rust
flakes-update:
	nix flake update
start-nix-shell:
	nix develop
rust-update:
	rustup update
	rust-analyzer --version

.PHONY: dockerBuild dockerRun dockerRm dockerShell dockerStartBook dockerBuildBook
.PHONY: all all-interactive all-build

dockerRm:
	sudo docker rm -f mydrummodule

dockerShell:
	sudo docker exec -it mydrummodule fish

dockerBuild:
	sudo docker build \
		--network=host \
		--build-arg USRNAME=$$(whoami) \
		--build-arg USR_UID=$$(id -u) \
		--build-arg USR_GID=$$(id -g) \
		--build-arg REPO_PATH=$$(pwd) \
		--build-arg HTTP_PROXY=$$http_proxy \
		--build-arg HTTPS_PROXY=$$https_proxy \
		-t mydrummoduleimage .

DOCKER_RUN_BASE_COMMAND= \
    sudo docker run \
    -v $$(pwd):$$(pwd) \
    --network host \
    --name mydrummodule \
    --env http_proxy=$$http_proxy \
    --env https_proxy=$$https_proxy

# if you are under a proxy please set on ~/.docker/config.json to the address 127.0.0.1:3128
dockerRun:
	$(DOCKER_RUN_BASE_COMMAND) -dit mydrummoduleimage "fish"

# # will start the webserver on localhost:3000
# dockerStartBook:
# 	$(DOCKER_RUN_BASE_COMMAND) -dit mydrummoduleimage "mdbook serve"
# 	@echo ""
# 	@echo "############################################"
# 	@echo "webserver started on http://localhost:3000"
# 	@echo "############################################"

# dockerBuildBook:
# 	$(DOCKER_RUN_BASE_COMMAND) mydrummoduleimage "mdbook build"

# all: dockerRm dockerBuild dockerStartBook
all-interactive: dockerRm dockerBuild dockerRun dockerShell
# all-build: dockerRm dockerBuild dockerBuildBook

