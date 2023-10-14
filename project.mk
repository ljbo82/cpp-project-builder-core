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

ifndef __project_mk__
__project_mk__ := 1

__project_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__project_mk_self_dir__)functions.mk

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
ifneq ($(call FN_INVALID_OPTION,$(V),0 1),)
    $(error [V] Invalid value: $(V))
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
ifneq ($(call FN_INVALID_OPTION,$(PROJ_TYPE),app lib custom-lib),)
    $(error [PROJ_TYPE] Invalid value: $(PROJ_TYPE))
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
ifneq ($(call FN_INVALID_OPTION,$(DEBUG),0 1),)
    $(error [DEBUG] Invalid value: $(DEBUG))
endif
# ------------------------------------------------------------------------------

# Check for transient dependency calculation (TDC) -----------------------------
__TDC__ ?= 0
ifneq ($(origin __TDC__),command line)
    $(error [__TDC__] Not defined via command-line (origin: $(origin __TDC__)))
endif
ifneq ($(call FN_INVALID_OPTION,$(__TDC__),0 1),)
    $(error [__TDC__] Invalid value: $(__TDC__))
endif
# ------------------------------------------------------------------------------

# Output directory -------------------------------------------------------------
ifeq ($(__TDC__),0)
    O ?= output
    ifeq ($(O),)
        $(error [O] Missing value)
    endif
    ifneq ($(words $(O)),1)
        $(error [O] Value cannot have whitespaces: $(O))
    endif
endif
# ------------------------------------------------------------------------------

# Build sub-directory ----------------------------------------------------------
ifeq ($(__TDC__),0)
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
endif
# ------------------------------------------------------------------------------

# Distribution sub-directory ---------------------------------------------------
ifeq ($(__TDC__),0)
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
endif
# ------------------------------------------------------------------------------

# Source directories -----------------------------------------------------------
ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        SKIP_DEFAULT_SRC_DIR ?= 0
        ifneq ($(origin SKIP_DEFAULT_SRC_DIR),file)
            $(error [SKIP_DEFAULT_SRC_DIR] Not defined in a makefile (origin: $(origin SKIP_DEFAULT_SRC_DIR)))
        endif
        ifneq ($(SKIP_DEFAULT_SRC_DIR),0)
            ifneq ($(SKIP_DEFAULT_SRC_DIR),1)
                $(error [SKIP_DEFAULT_SRC_DIR] Invalid value: $(SKIP_DEFAULT_SRC_DIR))
            endif
        endif

        ifdef SRC_DIRS
            ifneq ($(origin SRC_DIRS),file)
                $(error [SRC_DIRS] Not defined in a makefile (origin: $(origin SRC_DIRS)))
            endif
        endif
        ifeq ($(SKIP_DEFAULT_SRC_DIR),0)
            ifneq ($(wildcard src),)
                SRC_DIRS += src
            endif
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Manages target host ----------------------------------------------------------
include $(__project_mk_self_dir__)hosts.mk
# ------------------------------------------------------------------------------

# Strips release build ---------------------------------------------------------
ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        STRIP_RELEASE ?= 1
        ifneq ($(origin STRIP_RELEASE),file)
            $(error [STRIP_RELEASE] Not defined in a makefile (origin: $(origin STRIP_RELEASE)))
        endif
        ifeq ($(STRIP_RELEASE),)
            $(error [STRIP_RELEASE] Missing value)
        endif
        ifneq ($(STRIP_RELEASE),0)
            ifneq ($(STRIP_RELEASE),1)
                $(error [STRIP_RELEASE] Invalid value: $(STRIP_RELEASE))
            endif
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        OPTIMIZE_RELEASE ?= 1
        ifneq ($(origin OPTIMIZE_RELEASE),file)
            $(error [OPTIMIZE_RELEASE] Not defined in a makefile (origin: $(origin OPTIMIZE_RELEASE)))
        endif
        ifeq ($(OPTIMIZE_RELEASE),)
            $(error [OPTIMIZE_RELEASE] Missing value)
        endif
        ifneq ($(OPTIMIZE_RELEASE),0)
            ifneq ($(OPTIMIZE_RELEASE),1)
                $(error [OPTIMIZE_RELEASE] Invalid value: $(OPTIMIZE_RELEASE))
            endif
        endif
        ifneq ($(OPTIMIZE_RELEASE),0)
            RELEASE_OPTIMIZATION_LEVEL ?= 2
        endif
    endif
endif
# ------------------------------------------------------------------------------

# LIB_TYPE ----------------------------------------------------------------------

# NOTE: A host layer may have set a default LIB_TYPE

ifeq ($(__TDC__),0)
    ifeq ($(PROJ_TYPE),lib)
        LIB_TYPE ?= shared
        ifeq ($(LIB_TYPE),)
            $(error [LIB_TYPE] Missing value)
        endif
        ifneq ($(call FN_INVALID_OPTION,$(LIB_TYPE),shared static),)
            $(error [LIB_TYPE] Invalid value: $(LIB_TYPE))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ARTIFACT ---------------------------------------------------------------------

# NOTE: A host layer may have set a default ARTIFACT

ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        ARTIFACT ?= a.out
        ifeq ($(ARTIFACT),)
            $(error [ARTIFACT] Missing value)
        endif
        ifneq ($(words $(ARTIFACT)),1)
            $(error [ARTIFACT] Value cannot have whitespaces: $(ARTIFACT))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        ifdef SKIPPED_SRC_DIRS
            ifneq ($(origin SKIPPED_SRC_DIRS),file)
                $(error [SKIPPED_SRC_DIRS] Not defined in a makefile (origin: $(origin SKIPPED_SRC_DIRS)))
            endif
            SKIPPED_SRC_DIRS := $(call FN_UNIQUE,$(SKIPPED_SRC_DIRS))
        endif

        ifdef SKIPPED_SRC_FILES
            ifneq ($(origin SKIPPED_SRC_FILES),file)
                $(error [SKIPPED_SRC_FILES] Not defined in a makefile (origin: $(origin SKIPPED_SRC_FILES)))
            endif
            SKIPPED_SRC_FILES := $(call FN_UNIQUE,$(SKIPPED_SRC_FILES))
        endif

        ifdef SRC_FILES
            ifneq ($(origin SRC_FILES),file)
                $(error [SRC_FILES] Not defined in a makefile (origin: $(origin SRC_FILES)))
            endif
        endif

        SRC_DIRS := $(call FN_UNIQUE,$(filter-out $(SKIPPED_SRC_DIRS),$(SRC_DIRS)))

        # Checks if any SRC_DIR is outside CURDIR
        $(foreach srcDir,$(SRC_DIRS),$(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(srcDir)),,$(error [SRC_DIRS] Invalid directory: $(srcDir))))

        __project_mk_src_file_filter__ := $(subst //,/,$(foreach skippedSrcDir,$(SKIPPED_SRC_DIRS),-and -not -path '$(skippedSrcDir)/*')) -and -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S'

        SRC_FILES := $(call FN_UNIQUE,$(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f $(__project_mk_src_file_filter__) 2> /dev/null)) $(SRC_FILES)))

        __project_mk_invalid_src_files__ := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))

        ifneq ($(__project_mk_invalid_src_files__),)
            $(error [SRC_FILES] Unsupported source file(s): $(__project_mk_invalid_src_files__))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
ifeq ($(__TDC__),0)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        SKIP_DEFAULT_INCLUDE_DIR ?= 0
        ifneq ($(origin SKIP_DEFAULT_INCLUDE_DIR),file)
            $(error [SKIP_DEFAULT_INCLUDE_DIR] Not defined in a makefile (origin: $(origin SKIP_DEFAULT_INCLUDE_DIR)))
        endif

        ifneq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
            ifneq ($(SKIP_DEFAULT_INCLUDE_DIR),1)
                $(error [SKIP_DEFAULT_INCLUDE_DIR] Invalid value: $(SKIP_DEFAULT_INCLUDE_DIR))
            endif
        endif

        ifdef INCLUDE_DIRS
            ifneq ($(origin INCLUDE_DIRS),file)
                $(error [INCLUDE_DIRS] Not defined in a makefile (origin: $(origin INCLUDE_DIRS)))
            endif
        endif

        ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
            ifneq ($(wildcard include),)
                INCLUDE_DIRS += include
            endif
        endif

        INCLUDE_DIRS := $(call FN_UNIQUE,$(SRC_DIRS) $(INCLUDE_DIRS))
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

undefine __project_mk_src_file_filter__
undefine __project_mk_invalid_src_files__
undefine __project_mk_self_dir__

endif # ifndef __project_mk__
