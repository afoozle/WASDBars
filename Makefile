LUA_BIN := $(if $(wildcard .lua/bin),.lua/bin/,)
STYLUA := .tools/bin/stylua
STYLUA_VERSION := $(shell cat .stylua-version)
SRC := $(wildcard Core ActionBarCluster MainBarReplacement WasdLayoutMode Keybinds EditModeLayouts Setup Options Performance tests)

.PHONY: setup lint stylua-version format format-check test check

setup:
	scripts/setup-dev.sh

lint:
	$(LUA_BIN)luacheck .

stylua-version:
	@test "$$($(STYLUA) --version 2>/dev/null)" = "stylua $(STYLUA_VERSION)" \
		|| { echo "StyLua $(STYLUA_VERSION) isn't installed in .tools; run make setup."; exit 1; }

format: stylua-version
	$(STYLUA) $(SRC)

format-check: stylua-version
	$(STYLUA) --check $(SRC)

test:
	$(LUA_BIN)busted

check: lint format-check test
