export SHELL=/bin/bash

.DEFAULT_GOAL := sim

TOP ?= tb_top
ROOT_DIR := $(CURDIR)
BUILD_DIR := $(ROOT_DIR)/build
LOG_DIR := $(ROOT_DIR)/log

CORE_FILES := $(shell find $(ROOT_DIR) -maxdepth 1 -name "*.sv")
TOP_FILE := $(ROOT_DIR)/testbenches/$(TOP).sv
FILES := $(CORE_FILES)

ifneq ($(wildcard $(TOP_FILE)),)
FILES += $(TOP_FILE)
endif

EWLH := | grep -iE "error:|warning:|" --color=auto

.PHONY: print clean clean_full sim

print:
	@echo "TOP=$(TOP)"
	@echo "FILES=$(FILES)"

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
	@echo -e "\033[1;33mCleaned build directory:\033[0m $(BUILD_DIR)"

.PHONY: clean_full
clean_full:
	@$(MAKE) -s clean
	@rm -rf $(LOG_DIR)
	@echo -e "\033[1;33mCleaned log directory:\033[0m $(LOG_DIR)"

$(BUILD_DIR) $(LOG_DIR):
	@mkdir -p $@
	@echo "*" > $@/.gitignore
	@echo -e "\033[1;33mCreated directory:\033[0m $@"

.PHONY: sim
sim: $(BUILD_DIR) $(LOG_DIR)
	@echo -e "\033[1;33mStarting simulation for top-level module:\033[0m $(TOP)"
	@cd $(BUILD_DIR) && xvlog -sv $(FILES) -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log $(EWLH)
	@cd $(BUILD_DIR) && xelab $(TOP) -debug all -s snap_$(TOP) -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(EWLH)
	@cd $(BUILD_DIR) && xsim snap_$(TOP) -runall -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(EWLH)
