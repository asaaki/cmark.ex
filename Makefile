ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS?=-I$(ERLANG_PATH)
CC?=clang
EBIN_DIR?=ebin

ifeq ($(shell uname),Darwin)
	OPTIONS=-dynamiclib -undefined dynamic_lookup
endif

SRC_DIR=src
PRIV_DIR=priv
TMP_DIR=tmp

STMD=stmd
STMD_REPO=https://github.com/jgm/$(STMD).git
STMD_SRC_DIR=$(TMP_DIR)/$(STMD)
STMD_SCANNERS=scanners
STMD_SRC_SCANNERS_C=$(SRC_DIR)/$(STMD_SCANNERS).c
STMD_SRC_SCANNERS_C_PATH=$(STMD_SRC_DIR)/$(STMD_SRC_SCANNERS_C)

STMD_OBJS=\
	$(STMD_SRC_DIR)/$(SRC_DIR)/html/html.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/html/houdini_href_e.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/html/houdini_html_e.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/html/houdini_html_u.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/inlines.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/buffer.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/blocks.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/scanners.c \
	$(STMD_SRC_DIR)/$(SRC_DIR)/utf8.o \
	$(STMD_SRC_DIR)/$(SRC_DIR)/references.c

NIF_SRC=$(SRC_DIR)/$(STMD)_nif.c
NIF_LIB=$(PRIV_DIR)/$(STMD).so

CFLAGS?=-g -O3 -I$(STMD_SRC_DIR)/$(SRC_DIR)

all: $(NIF_LIB)

clone_stmd: $(STMD_SRC_DIR)

$(STMD_SRC_DIR): $(TMP_DIR)
	git clone --quiet --depth 1 --branch master $(STMD_REPO) $@

$(TMP_DIR):
	@mkdir -p $@ 2>&1 >/dev/null

$(PRIV_DIR):
	@mkdir -p $@ 2>&1 >/dev/null

build_scanners: $(STMD_SRC_DIR)
	cd $(STMD_SRC_DIR) && $(MAKE) $(STMD_SRC_SCANNERS_C) && \
	cd - && cp $(STMD_SRC_SCANNERS_C_PATH) $(STMD_SRC_SCANNERS_C)

place_scanners: $(STMD_SRC_SCANNERS_C) $(STMD_SRC_DIR)
	cp $(STMD_SRC_SCANNERS_C) $(STMD_SRC_SCANNERS_C_PATH) 2>&1 >/dev/null

$(STMD_SRC_SCANNERS_C_PATH): $(STMD_SRC_SCANNERS_C) $(STMD_SRC_DIR)
	@cp $(STMD_SRC_SCANNERS_C) $@ 2>&1 >/dev/null

$(NIF_LIB): $(STMD_SRC_DIR) $(STMD_OBJS) $(PRIV_DIR) $(NIF_SRC)
	$(CC) $(CFLAGS) \
		$(ERLANG_FLAGS) \
		-shared $(OPTIONS) \
		$(STMD_OBJS) \
		$(NIF_SRC) \
		-o $@

stmd_ex:
	@mix compile

clean:
	-rm -rf tmp
	-rm -rf priv

.PHONY: all stmd_ex clean clone_stmd build_scanners place_scanners
