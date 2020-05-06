CC?=clang
# this is required for local development and calling make directly
ERTS_INCLUDE_DIR?=$(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS?=-I$(ERTS_INCLUDE_DIR)
EBIN_DIR?=ebin

NOOUT=2>&1 >/dev/null

BUILD_DIR=_build
DEPS_DIR=deps
PRIV_DIR=priv
SRC_DIR=src
TEST_DIR=test
TMP_DIR=tmp

CMARK=cmark

CMARK_SRC_REPO=https://github.com/jgm/cmark.git
CMARK_SRC_DIR=$(TMP_DIR)/$(CMARK)
CMARK_C_SRC_DIR=$(CMARK_SRC_DIR)/$(SRC_DIR)
CMARK_C_FILES=$(sort $(filter-out %main.c %print.c, $(wildcard $(CMARK_C_SRC_DIR)/*.c)))
CMARK_H_FILES=$(sort $(wildcard $(CMARK_C_SRC_DIR)/*.h))
CMARK_INC_FILES=$(sort $(wildcard $(CMARK_C_SRC_DIR)/*.inc))
CMARK_BUILD_DIR=$(CMARK_SRC_DIR)/build

PYTHON=python3
CMARK_SPECS_DIR=$(CMARK_SRC_DIR)/test
CMARK_SPECS_FILE=$(CMARK_SPECS_DIR)/spec.txt
CMARK_SMART_PUNCT_FILE=$(CMARK_SPECS_DIR)/smart_punct.txt
CMARK_SPECS_RUNNER=$(CMARK_SPECS_DIR)/spec_tests.py
CMARK_SPECS_JSON=$(TEST_DIR)/$(CMARK)_specs.json
CMARK_SMART_PUNCT_JSON=$(TEST_DIR)/$(CMARK)_smart_punct.json

C_SRC_DIR=c_src
C_SRC_C_FILES=$(sort $(wildcard $(C_SRC_DIR)/*.c))
C_SRC_O_FILES=$(C_SRC_C_FILES:.c=.o)

NIF_SRC=$(SRC_DIR)/$(CMARK)_nif.c
NIF_LIB=$(PRIV_DIR)/$(CMARK).so

OPTIONS=-shared
ifeq ($(shell uname),Darwin)
OPTIONS+= -dynamiclib -undefined dynamic_lookup
endif
INCLUDES=-I$(C_SRC_DIR)

OPTFLAGS?=-fPIC -std=c99 -Wall
CFLAGS=-O2 $(OPTFLAGS) $(INCLUDES)
CMARK_OPTFLAGS=-DNDEBUG

### TARGETS

all: check-cc $(NIF_LIB)

all-dev: dev-prepare all

all-test: all test

all-dev-test: all-dev test

build-objects: $(C_SRC_O_FILES)

$(C_SRC_DIR)/%.o : $(C_SRC_DIR)/%.c
	$(CC) $(CMARK_OPTFLAGS) $(CFLAGS) -o $@ -c $<

$(C_SRC_DIR):
	mkdir -p $@

$(PRIV_DIR):
	@mkdir -p $@ $(NOOUT)

$(NIF_LIB): $(PRIV_DIR) $(C_SRC_O_FILES)
	$(CC) $(CFLAGS) $(ERLANG_FLAGS) $(OPTIONS) $(C_SRC_O_FILES) $(NIF_SRC) -o $@

$(CMARK):
	@mix deps.get
	@mix compile

### TEST

spec: all $(CMARK_SPECS_JSON) $(CMARK_SMART_PUNCT_JSON)
	@mix deps.get
	@mix test

test: spec

### LINT

lint:
	MIX_ENV=lint mix credo --strict

### PUBLISH

publish: publish-code

publish-code: all
	@mix hex.publish

### HELPERS/TOOLS

check-cc:
	@hash clang 2>/dev/null || \
	hash gcc 2>/dev/null || ( \
	echo '`clang` or `gcc` seem not to be installed or in your PATH.' && \
	echo 'Maybe you need to install one of it first.' && \
	exit 1)

docs:
	@MIX_ENV=docs mix docs

### CLEAN UP

clean: clean-objects clean-dirs

clean-objects:
	rm -f $(C_SRC_O_FILES)

clean-dirs: clean-tmp
	rm -rf $(BUILD_DIR) $(DEPS_DIR) $(PRIV_DIR)

clean-tmp:
	rm -rf $(TMP_DIR)

### DEVELOPMENT

dev-prepare: dev-prebuilt-lib dev-copy-code dev-copy-license dev-spec-dump dev-smart-punct-dump

$(CMARK_SRC_DIR):
	@mkdir -p $(TMP_DIR)
	@git clone --depth 1 $(CMARK_SRC_REPO) $@

dev-copy-code: $(C_SRC_DIR)
	cp \
		$(CMARK_C_FILES) \
		$(CMARK_H_FILES) \
		$(CMARK_INC_FILES) \
		$(CMARK_BUILD_DIR)/src/config.h \
		$(CMARK_BUILD_DIR)/src/cmark_export.h \
		$(CMARK_BUILD_DIR)/src/cmark_version.h \
	$(C_SRC_DIR)/

dev-copy-license: $(C_SRC_DIR)
	cp \
	$(CMARK_SRC_DIR)/COPYING \
	$(C_SRC_DIR)/

dev-prebuilt-lib: $(CMARK_SRC_DIR)
	mkdir -p $(CMARK_BUILD_DIR) && cd $(CMARK_BUILD_DIR) && cmake .. && $(MAKE)

dev-build-objects: dev-copy-code build-objects

$(CMARK_SPECS_JSON): dev-spec-dump
$(CMARK_SMART_PUNCT_JSON): dev-smart-punct-dump

dev-spec-dump: $(CMARK_SRC_DIR)
	@$(PYTHON) $(CMARK_SPECS_RUNNER) \
	--spec $(CMARK_SPECS_FILE) \
	--dump-tests | \
	jq -r -M -S "." > $(CMARK_SPECS_JSON) \
	|| true

dev-smart-punct-dump: $(CMARK_SRC_DIR)
	@$(PYTHON) $(CMARK_SPECS_RUNNER) \
	--spec $(CMARK_SMART_PUNCT_FILE) \
	--dump-tests | \
	jq -r -M -S "." > $(CMARK_SMART_PUNCT_JSON) \
	|| true

dev-clean:
	@rm -rf $(TMP_DIR)

### PHONY

.PHONY: all all-dev all-dev-test all-test check-cc clean dev-build-objects dev-copy-code dev-copy-license dev-prebuilt-lib dev-prepare dev-spec-dump docs spec test $(CMARK)
