CC?=clang
ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS?=-I$(ERLANG_PATH)
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

PYTHON=python
CMARK_SPECS_REPO=https://github.com/jgm/CommonMark.git
CMARK_SPECS_DIR=$(TMP_DIR)/specs
CMARK_SPECS_FILE=$(CMARK_SPECS_DIR)/spec.txt
CMARK_SPECS_RUNNER=$(CMARK_SPECS_DIR)/test/spec_tests.py
CMARK_SPECS_JSON=$(TEST_DIR)/$(CMARK)_specs.json

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

all: version check-cc $(NIF_LIB)

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

spec: all $(CMARK_SPECS_JSON)
	@mix deps.get
	@mix test

test: spec

### PUBLISH

publish: version docs publish-code publish-docs

publish-code: all
	@mix hex.publish

publish-docs: docs
	@MIX_ENV=docs mix hex.docs

### HELPERS/TOOLS

check-cc:
	@hash clang 2>/dev/null || \
	hash gcc 2>/dev/null || ( \
	echo '`clang` or `gcc` seem not to be installed or in your PATH.' && \
	echo 'Maybe you need to install one of it first.' && \
	exit 1)

docs:
	@MIX_ENV=docs mix docs

version:
	@echo "+==============+"
	@echo "| Cmark v`cat VERSION` |"
	@echo "+==============+"

### CLEAN UP

clean: clean-objects clean-dirs

clean-objects:
	rm -f $(C_SRC_O_FILES)

clean-dirs:
	rm -rf $(BUILD_DIR) $(DEPS_DIR) $(PRIV_DIR) $(TMP_DIR)

### DEVELOPMENT

dev-prepare: dev-prebuilt-lib dev-copy-code dev-spec-dump

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
	$(CMARK_SRC_DIR)/LICENSE \
	$(C_SRC_DIR)/

dev-prebuilt-lib: $(CMARK_SRC_DIR)
	mkdir -p $(CMARK_BUILD_DIR) && cd $(CMARK_BUILD_DIR) && cmake .. && $(MAKE)

dev-build-objects: dev-copy-code build-objects

$(CMARK_SPECS_JSON): dev-spec-dump

$(CMARK_SPECS_DIR):
	@mkdir -p $(TMP_DIR)
	@git clone --depth 1 $(CMARK_SPECS_REPO) $@

dev-spec-dump: $(CMARK_SPECS_DIR)
	@$(PYTHON) $(CMARK_SPECS_RUNNER) \
	--spec $(CMARK_SPECS_FILE) \
	--dump-tests > $(CMARK_SPECS_JSON) \
	|| true

### PHONY

.PHONY: all check-cc clean dev-build-objects dev-clean-deps dev-copy-code dev-prebuilt-lib dev-prepare dev-spec-dump dev-update-deps docs spec test $(CMARK)
