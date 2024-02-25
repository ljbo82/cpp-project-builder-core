# Copyright (c) 2022-2024 Leandro José Britto de Oliveira
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Common definitions for standalone makefiles

ifndef cpb_include_common_mk
cpb_include_common_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_include_common_mk))functions.mk

$(call FN_CHECK_RESERVED,CPB_VERSION)
$(call FN_CHECK_RESERVED,cpb_include_common_mk_min_make_version)
$(call FN_CHECK_RESERVED,cpb_include_common_mk_make_version)
$(call FN_CHECK_RESERVED,cpb_include_common_mk_make_version_cmp)
$(call FN_CHECK_RESERVED,cpb_include_common_mk_term_support_colors)
$(call FN_CHECK_RESERVED,cpb_include_common_mk_log_color)
$(call FN_CHECK_RESERVED,CPB_COLOR_LOG)
$(call FN_CHECK_RESERVED,CPB_LOG)

CPB_VERSION := 1.0.0
ifdef CPB_MIN_VERSION
    $(call FN_CHECK_NON_EMPTY,CPB_MIN_VERSION)
    $(call FN_CHECK_ORIGIN,CPB_MIN_VERSION,file)
    $(call FN_CHECK_NO_WHITESPACE,CPB_MIN_VERSION)
    $(if $(call FN_SEMVER_CMP,$(CPB_VERSION),$(CPB_MIN_VERSION)),,$(error [CPB_MIN_VERSION] Current version is not compatible: $(CPB_VERSION) (version should be $(CPB_MIN_VERSION)+)))
endif

# Checks if GNU Make is supported ----------------------------------------------
cpb_include_common_mk_min_make_version := 4.2
cpb_include_common_mk_make_version := $(word 3,$(call FN_SHELL,$(MAKE) --version | grep "GNU Make"))
cpb_include_common_mk_make_version_cmp := $(call FN_SEMVER_CMP,$(cpb_include_common_mk_make_version),$(cpb_include_common_mk_min_make_version))
$(if $(cpb_include_common_mk_make_version_cmp),,$(error Incompatible GNU Make version: $(if $(cpb_include_common_mk_make_version),$(cpb_include_common_mk_make_version),unknown) (version should be $(cpb_include_common_mk_min_make_version)+)))
# ------------------------------------------------------------------------------

# Output directory -------------------------------------------------------------
O ?= output
$(call FN_CHECK_NON_EMPTY,O)
$(call FN_CHECK_NO_WHITESPACE,O)
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
$(call FN_CHECK_NON_EMPTY,V)
$(call FN_CHECK_OPTIONS,V,0 1)
$(call FN_CHECK_RESERVED,VERBOSE)
VERBOSE := $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
cpb_include_common_mk_term_support_colors := $(shell tput colors 2> /dev/null)
ifneq ($(cpb_include_common_mk_term_support_colors),)
    ifneq ($(cpb_include_common_mk_term_support_colors),0)
        cpb_include_common_mk_term_support_colors := 1
    else
        cpb_include_common_mk_term_support_colors :=
    endif
endif

cpb_include_common_mk_log_color := 0
ifeq ($(V),1)
    ifeq ($(cpb_include_common_mk_term_support_colors),1)
        cpb_include_common_mk_log_color := 1
    endif
endif

# Printf command to show color log messages in recipes
#
# NOTE: Real color support relies on terminal support. If there is no support
#       Colors are ignored.
#
# Syntax: $(call CPB_COLOR_LOG,ansiColor?=,msgFmt,msgFmtArgs?=)
CPB_COLOR_LOG = @printf "$(if $(and $(cpb_include_common_mk_term_support_colors),$(1)),\033[$(1)m,)$(2)$(if $(and $(cpb_include_common_mk_term_support_colors),$(1)),\033[0m,)\n"$(if $(3), "$(3)",)

# Printf command to show log messages in recipes
#
# Syntax: $(call CPB_LOG,msgFmt,msgFmtArgs?=)
ifneq ($(cpb_include_common_mk_log_color),0)
    CPB_LOG = $(call CPB_COLOR_LOG,96,$(1),$(2))
else
    CPB_LOG = $(call CPB_COLOR_LOG,,$(1),$(2))
endif
# ------------------------------------------------------------------------------

endif # ifndef cpb_include_common_mk
