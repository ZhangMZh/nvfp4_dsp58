# SPDX-License-Identifier: MIT
PYTHON ?= python3
BUILD_DIR ?= build
PART ?= xcv80-lsva4737-2MHP-e-S
CLOCK_NS ?= 3.333333
TARGETS := test rtl-sim rtl-impl rtl-ip hls-csim hls-synth hls-cosim hls-ip ip-check dist

.PHONY: help $(TARGETS)
help:
	@echo "Targets: $(TARGETS)"
	@echo "Variables: BUILD_DIR PART CLOCK_NS PYTHON"

$(TARGETS):
	$(PYTHON) scripts/run.py $@ --build "$(BUILD_DIR)" --part "$(PART)" --period "$(CLOCK_NS)"
