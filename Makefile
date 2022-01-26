# Name of the filter file, *with* `.lua` file extension.
FILTER_FILE := $(wildcard *.lua)
# Name of the filter, *without* `.lua` file extension
FILTER_NAME = $(patsubst %.lua,%,$(FILTER_FILE))

# Allow to use a different pandoc binary, e.g. when testing.
PANDOC ?= pandoc
# Allow to adjust the diff command if necessary
DIFF = diff

# Reference doc for DOCX
REFERENCE_DOC = test/custom-reference.docx

# Arbitrary Unix epoch so that we can specify the build timestamp in
# the generated content the in SOURCE_DATE_EPOCH environment variable.
#
# This means that the generated output and expected output will not differ
# because the build timestamp is different.
#
# Please see: https://pandoc.org/MANUAL.html#reproducible-builds
UNIX_EPOCH = 1643338939

# Test that running the filter on the sample input document yields
# the expected output.
#
# The automatic variable `$<` refers to the first dependency
# (i.e., the filter file).
test: $(FILTER_FILE) $(REFERENCE_DOC) test/input.md
	export SOURCE_DATE_EPOCH=$(UNIX_EPOCH); \
	$(PANDOC) -f markdown --lua-filter=$< -t docx --standalone test/input.md \
		--reference-doc $(REFERENCE_DOC) | \
		$(DIFF) test/expected.docx -

# Ensure that the `test` target is run each time it's called.
.PHONY: test

# Re-generate the expected output. This file **must not** be a
# dependency of the `test` target, as that would cause it to be
# regenerated on each run, making the test pointless.
test/expected.docx: $(FILTER_FILE) $(REFERENCE_DOC) test/input.md
	export SOURCE_DATE_EPOCH=$(UNIX_EPOCH); \
	$(PANDOC) -f markdown --lua-filter=$< --standalone -t docx -o $@ \
		--reference-doc $(REFERENCE_DOC) test/input.md

#
# Docs
#
.PHONY: docs
docs: docs/index.html docs/$(FILTER_FILE)

docs/index.html: README.md test/input.md $(FILTER_FILE) .tools/docs.lua \
		docs/output.md docs/style.css
	@mkdir -p docs
	pandoc \
	    --standalone \
	    --lua-filter=.tools/docs.lua \
	    --metadata=sample-file:test/input.md \
	    --metadata=result-file:docs/output.md \
	    --metadata=code-file:$(FILTER_FILE) \
	    --css=style.css \
		--include-in-header=docs/header-includes.html \
	    --toc \
	    --output=$@ $<

docs/style.css:
	curl \
	    --output $@ \
	    'https://cdn.jsdelivr.net/gh/kognise/water.css@latest/dist/light.css'

docs/output.md: $(FILTER_FILE) test/input.md
	$(PANDOC) \
	    --output=$@ \
	    --lua-filter=$< \
	    --to=markdown \
	    --standalone \
	    test/input.md

docs/$(FILTER_FILE): $(FILTER_FILE)
	(cd docs && ln -sf ../$< $<)

.PHONY: clean
clean:
	rm -f docs/output.md docs/index.html docs/style.css
