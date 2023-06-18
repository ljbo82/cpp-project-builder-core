# Copyright (c) 2022 Leandro José Britto de Oliveira
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

ifndef __common_mk__
__common_mk__ := 1

# Common includes --------------------------------------------------------------
__common_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__common_mk_self_dir__)functions.mk
include $(__common_mk_self_dir__)host.mk

undefine __common_mk_self_dir__
# ------------------------------------------------------------------------------

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(shell pwd)),1)
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
ifeq ($(V),)
    $(error [V] Missing value)
endif
ifneq ($(V),0)
    ifneq ($(V),1)
        $(error [V] Invalid value: $(V))
    endif
endif
ifdef O_VERBOSE
    $(error [O_VERBOSE] Reserved variable)
endif
O_VERBOSE = $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

# Project name -----------------------------------------------------------------
ifeq ($(PROJ_NAME),)
    $(error [PROJ_NAME] Missing value)
endif
ifneq ($(origin PROJ_NAME),file)
    $(error [PROJ_NAME] Not defined in a makefile (origin: $(origin PROJ_NAME)))
endif
ifneq ($(words $(PROJ_NAME)),1)
    $(error [PROJ_NAME] Value cannot have whitespaces: $(PROJ_NAME))
endif
# ------------------------------------------------------------------------------

# Project type -----------------------------------------------------------------
ifeq ($(PROJ_TYPE),)
    $(error [PROJ_TYPE] Missing value)
endif
ifneq ($(origin PROJ_TYPE),file)
    $(error [PROJ_TYPE] Not defined in a makefile (origin: $(origin PROJ_TYPE)))
endif
ifneq ($(PROJ_TYPE),app)
    ifneq ($(PROJ_TYPE),lib)
        $(error [PROJ_TYPE] Invalid value: $(PROJ_TYPE))
    endif
endif
# ------------------------------------------------------------------------------

# Project version --------------------------------------------------------------
PROJ_VERSION ?= 0.1.0
ifneq ($(origin PROJ_VERSION),file)
    $(error [PROJ_VERSION] Not defined in a makefile (origin: $(origin PROJ_VERSION)))
endif
ifeq ($(PROJ_VERSION),)
    $(error [PROJ_VERSION] Missing value)
endif
ifeq ($(call FN_SEMVER_CHECK,$(PROJ_VERSION)),)
    $(error [PROJ_VERSION] Invalid semantic version: $(PROJ_VERSION))
endif
# ------------------------------------------------------------------------------

# Debug / release --------------------------------------------------------------
DEBUG ?= 0
ifeq ($(DEBUG),)
    $(error [DEBUG] Missing value)
endif
ifneq ($(DEBUG),0)
    ifneq ($(DEBUG),1)
        $(error [DEBUG] Invalid value: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# Output directory -------------------------------------------------------------
O ?= output
ifeq ($(O),)
    $(error [O] Missing value)
endif
ifneq ($(words $(O)),1)
    $(error [O] Value cannot have whitespaces: $(O))
endif
# ------------------------------------------------------------------------------

# Build sub-directory ----------------------------------------------------------
ifneq ($(BUILD_SUBDIR),)
    ifneq ($(words $(BUILD_SUBDIR)),1)
        $(error [BUILD_SUBDIR] Value cannot have whitespaces: $(BUILD_SUBDIR))
    endif
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(BUILD_SUBDIR)),,$(error [BUILD_SUBDIR] Invalid path: $(BUILD_SUBDIR)))
endif
ifdef O_BUILD_DIR
    $(error [O_BUILD_DIR] Reserved variable)
else
    O_BUILD_DIR := $(O)/build
    ifneq ($(BUILD_SUBDIR),)
        O_BUILD_DIR := $(O_BUILD_DIR)/$(BUILD_SUBDIR)
    endif
endif
# ------------------------------------------------------------------------------

# Distribution sub-directory ---------------------------------------------------
ifneq ($(DIST_SUBDIR),)
    ifneq ($(words $(DIST_SUBDIR)),1)
        $(error [DIST_SUBDIR] Value cannot have whitespaces: $(DIST_SUBDIR))
    endif
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(DIST_SUBDIR)),,$(error [DIST_SUBDIR] Invalid path: $(DIST_SUBDIR)))
endif
ifdef O_DIST_DIR
    $(error [O_DIST_DIR] Reserved variable)
else
    O_DIST_DIR := $(O)/dist
    ifneq ($(DIST_SUBDIR),)
        O_DIST_DIR := $(DIST_SUBDIR)/$(DIST_SUBDIR)
    endif
endif
# ------------------------------------------------------------------------------

# Libs sub-directory -----------------------------------------------------------
ifeq ($(PROJ_TYPE),lib)
    LIBS_SUBDIR ?=
else
    LIBS_SUBDIR ?= libs
endif

override LIBS_SUBDIR := $(strip $(LIBS_SUBDIR))

ifneq ($(LIBS_SUBDIR),)
    ifneq ($(words $(LIBS_SUBDIR)),1)
        $(error [LIBS_SUBDIR] Value cannot have whitespaces)
    endif
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(LIBS_SUBDIR)),,$(error [LIBS_SUBDIR] Invalid path: $(LIBS_SUBDIR)))
else
    override LIBS_SUBDIR := .
endif
# ------------------------------------------------------------------------------

endif # ifndef __common_mk__
