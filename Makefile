.PHONY: build html server format reload

build b:
	@rm -rf docs/
	@mkdir docs/
	@make html

html h:
	@cp -R sources/assets/* docs/
	sources/build.exs

# An infinite loop to rebuild each second
reload r:
	while sleep 1; do make html; done

server s:
	@make build
	@echo "http://localhost:8000"
	@cd docs && python3 -m http.server

format f:
	mix format sources/build.exs
	mix format sources/template.html.eex
