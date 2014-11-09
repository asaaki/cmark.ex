ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS?=-I$(ERLANG_PATH)
CC?=clang
EBIN_DIR?=ebin

OPTIONS=-shared
ifeq ($(shell uname),Darwin)
	OPTIONS+= -dynamiclib -undefined dynamic_lookup
endif

NOOUT=2>&1 >/dev/null

PRIV_DIR=priv
SRC_DIR=src

CMARK_SRC_DIR=c_src
CMARK_C_SRC_DIR=$(CMARK_SRC_DIR)/$(SRC_DIR)
CMARK_BUILD_DIR=c_build
CMARK_BUILD_SRC_DIR=$(CMARK_BUILD_DIR)/$(SRC_DIR)

CMARK=cmark
CMARK_SO=$(CMARK_BUILD_SRC_DIR)/lib$(CMARK).so

NIF_SRC=$(SRC_DIR)/$(CMARK)_nif.c
NIF_LIB=$(PRIV_DIR)/$(CMARK).so

OPTFLAGS?=-fPIC
CFLAGS?=-g -O3 $(OPTFLAGS)

all: prerequisites $(NIF_LIB)

check-make:
	@hash make 2>/dev/null || ( \
	echo '`make` seems not to be installed or in your PATH.' && \
	echo 'Maybe you need to install it first.' && \
	exit 1)

check-cmake:
	@hash cmake 2>/dev/null || ( \
	echo '`cmake` seems not to be installed or in your PATH.' && \
	echo 'Maybe you need to install it first.' && \
	exit 1)

check-re2c:
	@hash re2c 2>/dev/null || ( \
	echo '`re2c` seems not to be installed or in your PATH.' && \
	echo 'Maybe you need to install it first.' && \
	exit 1)

prerequisites: check-make check-cmake check-re2c

update-deps:
	git submodule update --init

$(CMARK_SO):
	mkdir -p $(CMARK_BUILD_DIR) && \
		cd $(CMARK_BUILD_DIR) && \
		cmake ../$(CMARK_SRC_DIR) && \
		$(MAKE) $(CMARK)-shared

$(PRIV_DIR):
	@mkdir -p $@ $(NOOUT)

$(NIF_LIB): $(PRIV_DIR) $(CMARK_SO)
	$(CC) $(CFLAGS) $(ERLANG_FLAGS) $(OPTIONS) \
		-I$(CMARK_C_SRC_DIR) \
		$(shell find $(CMARK_BUILD_DIR) -name "*.o") \
		$(NIF_SRC) -o $@

$(CMARK):
	@mix deps.get
	@mix compile

spec: all $(CMARK)
	@perl \
		$(CMARK_SRC_DIR)/runtests.pl \
		$(CMARK_SRC_DIR)/spec.txt \
		./cmark_spec_runner

clean:
	-rm -rf $(CMARK_BUILD_DIR) $(PRIV_DIR)

.PHONY: all check-cmake check-make check-re2c clean prerequisites spec update-deps $(CMARK)
