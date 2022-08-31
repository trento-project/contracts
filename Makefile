SCHEMAS = ./schema
SUBDIRS := go elixir

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

add-schema:
	cat $(SCHEMAS)/schema.json.example | envsubst > $(SCHEMAS)/trento.$(project).v$(version).$(source).$(factname).schema.json
	
clean:
	cd go; $(MAKE) clean
	cd elixir; $(MAKE) clean

.PHONY: add-schema all $(SUBDIRS) clean
