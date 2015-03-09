PKG_REVISION	?= $(shell git describe --tags)
PKG_BUILD		= 1
APP_NAME		= harvester
BASE_DIR		= $(shell pwd)
DIST_DIR		= $(BASE_DIR)/rel/$(APP_NAME)
DIST_DATA_DIR	= $(DIST_DIR)/www/data
DATA_DIR		= $(HOME)/$(APP_NAME)/data

ERLANG_BIN		= $(shell dirname $(shell which erl))
REBAR           =  rebar
REBAR_OPTS      =
OVERLAY_VARS    ?=

$(if $(ERLANG_BIN),,$(warning "Warning: No Erlang found in your path, this will probably not work"))

.PHONY: rel deps redo delete_pisec get_pisec init dirs

all:	deps compile

redo:	delete_pisec deps compile generate
		@echo "done"

init:   dirs
        @echo "BASE_DIR is: $(BASE_DIR)"
        @echo "DIST_DIR is: $(DIST_DIR)"
        @echo "DIST_DATA_DIR is: $(DIST_DATA_DIR)"
        @echo "DATA_DIR is: $(DATA_DIR)"

dirs:   $(DATA_DIR)

link:   dirs
		ln -s $(DATA_DIR)/upload $(DIST_DATA_DIR)/upload
		ln -s $(DATA_DIR)/results $(DIST_DATA_DIR)/results

$(DATA_DIR):
		mkdir -p $@/results
		mkdir -p $@/upload

delete_pisec:
		rm -rf deps/pisec

compile:
		$(REBAR) $(REBAR_OPTS) compile

deps:
		$(REBAR) $(REBAR_OPTS) get-deps

clean: testclean
		$(REBAR) $(REBAR_OPTS) clean

distclean: clean devclean relclean ballclean
		$(REBAR) $(REBAR_OPTS) delete-deps

generate:
		$(REBAR) $(REBAR_OPTS) --force generate $(OVERLAY_VARS)

rel: init deps compile generate link                                