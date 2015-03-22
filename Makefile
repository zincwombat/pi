PKG_REVISION    ?= $(shell git describe --tags)
PKG_BUILD		= 1
APP_NAME		= picontroller
BASE_DIR		= $(shell pwd)
DIST_DIR		= $(BASE_DIR)/rel/$(APP_NAME)
DIST_DATA_DIR   = $(DIST_DIR)/www/data
DATA_DIR		= $(HOME)/$(APP_NAME)/data

ERLANG_BIN		= $(shell dirname $(shell which erl))
REBAR           = rebar
REBAR_OPTS      = 
OVERLAY_VARS    ?= ""

REBAR_CONFIG_X86=rebar.config.x86
RELEASE_CONFIG_X86=reltool.config.x86
REBAR_CONFIG_PI=rebar.config.pi
RELEASE_CONFIG_PI=reltool.config.pi
SYSCONFIG_PI=sys.config.pi
SYSCONFIG_X86=sys.config.x86

# =============================================================================
# Verify that the programs we need to run are installed on this system
# =============================================================================

ERL = $(shell which erl)
ifeq ($(ERL),)
$(error "Erlang not available on this system")
endif

REBAR=$(shell which rebar)
ifeq ($(REBAR),)
$(error "Rebar not available on this system")
endif

ARCHTYPE=$(shell uname -m)
REL=rel

ifeq ($(ARCHTYPE),x86_64)
$(info "(Intel x86 architecture detected) [$(ARCHTYPE)]")
REBAR_CONFIG=$(REBAR_CONFIG_X86)
RELEASE_CONFIG=$(RELEASE_CONFIG_X86)
SYS_CONFIG=$(SYSCONFIG_X86)
endif

ifeq ($(ARCHTYPE),armv6l)
$(info "(Raspberry Pi (ARM6) architecture detected) [$(ARCHTYPE)]")
REBAR_CONFIG=$(REBAR_CONFIG_PI)
RELEASE_CONFIG=$(RELEASE_CONFIG_PI)
SYS_CONFIG=$(SYSCONFIG_PI)
endif

ifeq ($(ARCHTYPE),armv7l)
$(info "(Raspberry Pi (ARM7) architecture detected) [$(ARCHTYPE)]")
REBAR_CONFIG=$(REBAR_CONFIG_PI)
RELEASE_CONFIG=$(RELEASE_CONFIG_PI)
SYS_CONFIG=$(SYSCONFIG_PI)
endif

$(if $(ERLANG_BIN),,$(warning "Warning: No Erlang found in your path, this will probably not work"))

.PHONY: rel deps redo delete_pisec get_pisec init 

all:    deps compile

redo:   delete_pisec deps compile generate
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

# $(DATA_DIR):
# 		mkdir -p $@/results
# 		mkdir -p $@/upload

delete_pisec:
	rm -rf deps/pisec

compile:	
	$(REBAR) $(REBAR_OPTS) compile

deps:
	$(REBAR) $(REBAR_OPTS) get-deps

clean:		testclean
	$(REBAR) $(REBAR_OPTS) clean

distclean:	clean devclean relclean ballclean
	$(REBAR) $(REBAR_OPTS) delete-deps

generate:
	$(REBAR) $(REBAR_OPTS) --force generate $(OVERLAY_VARS)

rel:	init deps compile generate link
