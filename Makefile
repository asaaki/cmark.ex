ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS?=-I$(ERLANG_PATH)
CC?=clang
EBIN_DIR?=ebin

OPTIONS=-shared
ifeq ($(shell uname),Darwin)
	OPTIONS+= -dynamiclib -undefined dynamic_lookup
endif

NOOUT=2>&1 >/dev/null

BUILD_DIR=_build
PRIV_DIR=priv
SRC_DIR=src
TEST_DIR=test

CMARK_SRC_DIR=c_src
CMARK_C_SRC_DIR=$(CMARK_SRC_DIR)/$(SRC_DIR)
CMARK_BUILD_DIR=$(CMARK_SRC_DIR)/build
CMARK_BUILD_SRC_DIR=$(CMARK_BUILD_DIR)/$(SRC_DIR)

CMARK=cmark
CMARK_LIB=lib$(CMARK)
CMARK_LIB_DIR=$(shell find . -type d -name "$(CMARK_LIB)*")
CMARK_SO=$(CMARK_BUILD_SRC_DIR)/$(CMARK_LIB).so
CMARK_SPECS_JSON=$(TEST_DIR)/$(CMARK)_specs.json

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
	cd $(CMARK_SRC_DIR) && git checkout master && git pull

$(CMARK_SO):
	mkdir -p $(CMARK_BUILD_DIR) && \
		cd $(CMARK_BUILD_DIR) && \
		cmake .. && \
		$(MAKE)

$(PRIV_DIR):
	@mkdir -p $@ $(NOOUT)

$(NIF_LIB): $(PRIV_DIR) $(CMARK_SO)
	$(CC) $(CFLAGS) $(ERLANG_FLAGS) $(OPTIONS) \
		-I$(CMARK_C_SRC_DIR) \
		-I$(CMARK_BUILD_SRC_DIR) \
		$(shell find $(CMARK_LIB_DIR) -name "*.o") \
		$(NIF_SRC) -o $@

$(CMARK):
	@mix deps.get
	@mix compile

spec: all spec-dump spec-reference
	@mix deps.get
	@mix test

spec-reference: $(CMARK_SO)
	-cd $(CMARK_SRC_DIR) && $(MAKE) test

test: spec

spec-dump: clean-$(CMARK_SPECS_JSON)
	@python $(CMARK_SRC_DIR)/runtests.py \
		--spec $(CMARK_SRC_DIR)/spec.txt \
		--dump-tests > $(CMARK_SPECS_JSON) \
	|| true

clean:
	cd $(CMARK_SRC_DIR) && $(MAKE) clean
	rm -rf $(CMARK_BUILD_DIR) $(PRIV_DIR) $(BUILD_DIR) $(CMARK_SPECS_JSON)

clean-$(CMARK_SPECS_JSON):
	@rm -f $(CMARK_SPECS_JSON)

.PHONY: all check-cmake check-make check-re2c clean clean-$(CMARK_SPECS_JSON) prerequisites spec spec-dump spec-reference test update-deps $(CMARK)
