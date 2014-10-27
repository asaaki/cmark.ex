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

CMARK=cmark
CMARK_REPO=https://github.com/jgm/CommonMark.git
CMARK_SRC_DIR=$(TMP_DIR)/$(CMARK)
CMARK_SCANNERS=scanners
CMARK_SRC_SCANNERS_C=$(SRC_DIR)/$(CMARK_SCANNERS).c
CMARK_SRC_SCANNERS_C_PATH=$(CMARK_SRC_DIR)/$(CMARK_SRC_SCANNERS_C)

CMARK_OBJS=\
	$(CMARK_SRC_DIR)/$(SRC_DIR)/html/html.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/html/houdini_href_e.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/html/houdini_html_e.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/html/houdini_html_u.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/inlines.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/buffer.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/blocks.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/scanners.c \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/utf8.o \
	$(CMARK_SRC_DIR)/$(SRC_DIR)/references.c

NIF_SRC=$(SRC_DIR)/$(CMARK)_nif.c
NIF_LIB=$(PRIV_DIR)/$(CMARK).so

OPTFLAGS?=-fPIC
CFLAGS?=-g -O3 $(OPTFLAGS) -I$(CMARK_SRC_DIR)/$(SRC_DIR)

all: $(NIF_LIB)

clone_CMARK: $(CMARK_SRC_DIR)

$(CMARK_SRC_DIR): $(TMP_DIR)
	git clone --quiet --depth 10 --branch master $(CMARK_REPO) $@

$(TMP_DIR):
	@mkdir -p $@ 2>&1 >/dev/null

$(PRIV_DIR):
	@mkdir -p $@ 2>&1 >/dev/null

build_scanners: $(CMARK_SRC_DIR)
	cd $(CMARK_SRC_DIR) && $(MAKE) $(CMARK_SRC_SCANNERS_C) && \
	cd - && cp $(CMARK_SRC_SCANNERS_C_PATH) $(CMARK_SRC_SCANNERS_C)

place_scanners: $(CMARK_SRC_SCANNERS_C) $(CMARK_SRC_DIR)
	cp $(CMARK_SRC_SCANNERS_C) $(CMARK_SRC_SCANNERS_C_PATH) 2>&1 >/dev/null

$(CMARK_SRC_SCANNERS_C_PATH): $(CMARK_SRC_SCANNERS_C) $(CMARK_SRC_DIR)
	@cp $(CMARK_SRC_SCANNERS_C) $@ 2>&1 >/dev/null

$(NIF_LIB): $(CMARK_SRC_DIR) $(CMARK_OBJS) $(PRIV_DIR) $(NIF_SRC)
	$(CC) $(CFLAGS) \
		$(ERLANG_FLAGS) \
		-shared $(OPTIONS) \
		$(CMARK_OBJS) \
		$(NIF_SRC) \
		-o $@

CMARK_ex:
	@mix compile

spec:	all
	@perl \
		${CMARK_SRC_DIR}/runtests.pl \
		${CMARK_SRC_DIR}/spec.txt \
		./cmark_spec_runner

clean:
	-rm -rf tmp
	-rm -rf priv

.PHONY: all CMARK_ex clean clone_CMARK build_scanners place_scanners
