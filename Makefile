# Absolute paths of all Makefiles' directories; we only have one Makefile.
# https://stackoverflow.com/a/29071831
doc_root:=$(dir $(abspath $(MAKEFILE_LIST)))

# We can run Docker with the --user <id> option to trick it into generating
# files as the specified user ID. Figure out $(doc_root)'s owner and use that.
user_id=$(shell stat -c '%u:%g' $(doc_root))

.SUFFIXES:

.PHONY: start-docker
start-docker: /.dockerenv

# Docker unofficially creates this file in containers.
/.dockerenv:
	docker run \
		--rm \
		--interactive=false \
		--tty=false \
		--user "$(user_id)" \
		--volume "$(doc_root):/documents/" \
		asciidoctor/docker-asciidoctor:latest \
		$(MAKE) all

.PHONY: all
all: man

.PHONY: man
man: nvi.1

%.1: %.1.adoc
	asciidoctor \
		--doctype manpage \
		--backend manpage \
		--out-file $@ \
		-- \
		$<
