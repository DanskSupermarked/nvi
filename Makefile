.SUFFIXES:

.PHONY: man
man: nvi.1

%.1: %.1.adoc
	docker run \
		--rm \
		--user "1000:1000" \
		--volume $(PWD):/documents/ \
		asciidoctor/docker-asciidoctor:latest \
		asciidoctor \
		--doctype manpage \
		--backend manpage \
		--out-file $@ \
		$<
