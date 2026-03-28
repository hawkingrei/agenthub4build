NPM := npm --cache ./.npm-cache
PPTX_OUTPUT := agenthub-team-tidb-shiro.pptx

.PHONY: install dev build pptx

install:
	$(NPM) install

dev:
	$(NPM) run dev

build:
	$(NPM) run build

pptx:
	TMPDIR=$${TMPDIR:-/tmp} npx slidev export --format pptx --output $(PPTX_OUTPUT)
