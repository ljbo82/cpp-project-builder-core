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

# Common definitions

ifndef cpb_functions_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_include_common_mk
cpb_include_common_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_include_common_mk))../native.mk

$(call fn_check_reserved,CPB_VERSION)
$(call fn_check_reserved,cpb_include_common_mk_min_make_version)
$(call fn_check_reserved,cpb_include_common_mk_make_version)
$(call fn_check_reserved,cpb_include_common_mk_make_version_cmp)

CPB_VERSION := 0.1.0
ifdef CPB_MIN_VERSION
    $(call fn_check_not_empty,CPB_MIN_VERSION)
    $(call fn_check_origin,CPB_MIN_VERSION,file)
    $(call fn_check_no_whitespace,CPB_MIN_VERSION)
    $(call fn_semver_check_compat,$(CPB_MIN_VERSION),$(CPB_VERSION),[CPB_MIN_VERSION] Current version is not compatible: $(CPB_VERSION) (version should be $(CPB_MIN_VERSION)+))
endif

override CPB_DIR := $(realpath $(dir $(cpb_include_common_mk)))

# Checks if GNU Make version is supported ----------------------------------------------
cpb_include_common_mk_min_make_version := 4.2
cpb_include_common_mk_make_version := $(word 3,$(call fn_shell,$(MAKE) --version | grep "GNU Make"))
$(call fn_semver_check_compat,$(cpb_include_common_mk_min_make_version),$(cpb_include_common_mk_make_version),Incompatible GNU Make version: $(if $(cpb_include_common_mk_make_version),$(cpb_include_common_mk_make_version),unknown) (version should be $(cpb_include_common_mk_min_make_version)+))
# ------------------------------------------------------------------------------

# Only one target per make call ------------------------------------------------
ifneq ($(words $(MAKECMDGOALS)),0)
    ifneq ($(words $(MAKECMDGOALS)),1)
        $(error Only one target can be called per time)
    endif
endif
# ------------------------------------------------------------------------------

# Debug / release --------------------------------------------------------------
DEBUG ?= 0
$(call fn_check_not_empty,DEBUG)
$(call fn_check_no_whitespace,DEBUG)
$(call fn_check_options,DEBUG,0 1)
# ------------------------------------------------------------------------------

# HOST -------------------------------------------------------------------------
ifndef HOST
    ifdef NATIVE_HOST
        HOST := $(NATIVE_HOST)
    endif
endif

$(call fn_check_not_empty,HOST)
$(call fn_check_no_whitespace,HOST)
# ------------------------------------------------------------------------------

# Output directory -------------------------------------------------------------
$(call fn_check_reserved,O_BASE)
ifdef O
    $(call fn_check_not_empty,O)
    $(call fn_check_no_whitespace,O)
    O_BASE := $(O)
else
    O_BASE := output
    O := $(O_BASE)/$(HOST)/$(if $(call fn_eq,$(DEBUG),0),release,debug)
endif

ifeq ($(realpath $(O)),$(CURDIR))
    $(error [O] Project root cannot be used as output directory)
endif
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
$(call fn_check_not_empty,V)
$(call fn_check_options,V,0 1)
$(call fn_check_reserved,V_PREFIX)
V_PREFIX := $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

VARS += CPB_DIR CPB_VERSION CPB_MIN_VERSION DEBUG HOST O O_BASE

endif # ifndef cpb_include_common_mk
