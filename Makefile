LUA_BIN := $(if $(wildcard .lua/bin),.lua/bin/,)
SRC := $(wildcard Core Logic Data UI tests)

.PHONY: setup lint format format-check test check

setup:
	scripts/setup-dev.sh

lint:
	$(LUA_BIN)luacheck .

format:
	stylua $(SRC)

format-check:
	stylua --check $(SRC)

test:
	$(LUA_BIN)busted

check: lint format-check test
