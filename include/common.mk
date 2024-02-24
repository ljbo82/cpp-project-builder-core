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

CPB_VERSION := 1.0.0
ifdef CPB_MIN_VERSION
    $(call FN_CHECK_ORIGIN,CPB_MIN_VERSION,file)
    $(if $(call FN_SEMVER_CMP,$(CPB_VERSION),$(CPB_MIN_VERSION)),,$(error [CPB_MIN_VERSION] Current version is not compatible: $(CPB_VERSION) (version should be $(CPB_MIN_VERSION)+)))
endif

# Checks if GNU Make is supported ----------------------------------------------
cpb_include_common_mk_min_make_version := 4.2
cpb_include_common_mk_make_version := $(word 3,$(shell $(MAKE) --version | grep "GNU Make"))
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

endif # ifndef cpb_include_common_mk
