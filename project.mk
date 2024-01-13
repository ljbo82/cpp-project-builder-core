# Copyright (c) 2023 Leandro José Britto de Oliveira
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

# Project definitions

ifndef project_mk
project_mk := 1

override undefine project_mk_self_dir
override undefine project_mk_src_file_filter
override undefine project_mk_invalid_src_files

project_mk_self_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(project_mk_self_dir)include/functions.mk
include $(project_mk_self_dir)include/common.mk
include $(project_mk_self_dir)include/native.mk

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(shell pwd)),1)
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Project type -----------------------------------------------------------------
ifeq ($(PROJ_TYPE),)
    $(error [PROJ_TYPE] Missing value)
endif
$(call FN_CHECK_ORIGIN,PROJ_TYPE,file)
$(call FN_CHECK_WORDS,PROJ_TYPE,app lib)
# ------------------------------------------------------------------------------

# Project name -----------------------------------------------------------------
ifeq ($(PROJ_NAME),)
    $(error [PROJ_NAME] Missing value)
endif
$(call FN_CHECK_ORIGIN,PROJ_NAME,file)
ifneq ($(words $(PROJ_NAME)),1)
    $(error [PROJ_NAME] Value cannot have whitespaces: $(PROJ_NAME))
endif
# ------------------------------------------------------------------------------

# deps =========================================================================
ifneq ($(filter deps,$(MAKECMDGOALS)),)
    ifneq ($(MAKECMDGOALS),deps)
        $(error deps cannot be invoked along with other targets (extra targets: $(filter-out deps,$(MAKECMDGOALS))))
    endif
endif

.PHONY: deps
deps:
	@printf -- "$(strip $(DEPS))"
# ==============================================================================

# print-vars ===================================================================
ifneq ($(filter print-vars,$(MAKECMDGOALS)),)
    ifneq ($(words $(MAKECMDGOALS)),1)
        $(error print-vars cannot be invoked along with other targets (extra targets: $(filter-out print-vars,$(MAKECMDGOALS))))
    endif
endif

VARS ?= $(sort O V VERBOSE PROJ_TYPE PROJ_NAME DEPS PROJ_VERSION DEBUG BUILD_SUBDIR O_BUILD_DIR DIST_SUBDIR O_DIST_DIR SKIP_DEFAULT_SRC_DIR SRC_DIRS NATIVE_OS NATIVE_ARCH NATIVE_HOST HOST SKIP_DEFAULT_HOSTS_DIR HOSTS_DIRS STRIP_RELEASE OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL LIB_TYPE ARTIFACT SKIPPED_SRC_DIRS SKIPPED_SRC_FILES SRC_FILES SKIP_DEFAULT_INCLUDE_DIR INCLUDE_DIRS MK_EXTRA_INCLUDES MK_EXTRA_EVAL LIBS CROSS_COMPILE AS ASFLAGS CC CFLAGS CXX CXXFLAGS AR ARFLAGS LD LDFLAGS PRE_CLEAN_DEPS CLEAN_DEPS POST_CLEAN_DEPS PRE_BUILD_DEPS BUILD_DEPS POST_BUILD_DEPS DIST_MARKER DIST_DIRS DIST_FILES PRE_DIST_DEPS DIST_DEPS POST_DIST_DEPS EXTRA_CFLAGS EXTRA_CXXFLAGS EXTRA_ASFLAGS EXTRA_ARFLAGS EXTRA_LDFLAGS)

.PHONY: print-vars
print-vars:
    ifeq ($(VARS),)
	    $(error [VARS] Missing value)
    endif
	$(foreach varName,$(VARS),$(info $(varName) = $($(varName))))
	@printf ''
# ==============================================================================

# Project version --------------------------------------------------------------
PROJ_VERSION ?= 0.1.0
$(call FN_CHECK_ORIGIN,PROJ_VERSION,file)
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
$(call FN_CHECK_WORDS,DEBUG,0 1)
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

# SKIP_DEFAULT_SRC_DIR ---------------------------------------------------------
SKIP_DEFAULT_SRC_DIR ?= 0
$(call FN_CHECK_ORIGIN,SKIP_DEFAULT_SRC_DIR,file)
$(call FN_CHECK_NON_EMPTY,SKIP_DEFAULT_SRC_DIR)
$(call FN_CHECK_WORDS,SKIP_DEFAULT_SRC_DIR,0 1)
ifdef SRC_DIRS
    $(call FN_CHECK_ORIGIN,SRC_DIRS,file)
endif
# ------------------------------------------------------------------------------

# SKIP_DEFAULT_INCLUDE_DIR -----------------------------------------------------
SKIP_DEFAULT_INCLUDE_DIR ?= 0
$(call FN_CHECK_ORIGIN,SKIP_DEFAULT_INCLUDE_DIR,file)
$(call FN_CHECK_NON_EMPTY,SKIP_DEFAULT_INCLUDE_DIR)
$(call FN_CHECK_WORDS,SKIP_DEFAULT_INCLUDE_DIR,0 1)
ifdef INCLUDE_DIRS
    $(call FN_CHECK_ORIGIN,INCLUDE_DIRS,file)
endif
# ------------------------------------------------------------------------------

# Manages host layers ----------------------------------------------------------
include $(project_mk_self_dir)include/hosts.mk
# ------------------------------------------------------------------------------

# Strips release build ---------------------------------------------------------
# NOTE: A host layer may have set STRIP_RELEASE
STRIP_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,STRIP_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,STRIP_RELEASE)
$(call FN_CHECK_WORDS,STRIP_RELEASE,0 1)
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
# NOTE: A host layer may have set OPTIMIZE_RELEASE and RELEASE_OPTIMIZATION_LEVEL
OPTIMIZE_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,OPTIMIZE_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,OPTIMIZE_RELEASE)
$(call FN_CHECK_WORDS,OPTIMIZE_RELEASE,0 1)
ifneq ($(OPTIMIZE_RELEASE),0)
    RELEASE_OPTIMIZATION_LEVEL ?= 2
endif
# ------------------------------------------------------------------------------

# LIB_TYPE ---------------------------------------------------------------------
# NOTE: A host layer may have set LIB_TYPE
LIB_TYPE ?= shared
ifeq ($(LIB_TYPE),)
    $(error [LIB_TYPE] Missing value)
endif
$(call FN_CHECK_WORDS,LIB_TYPE,shared static)
# ------------------------------------------------------------------------------

# ARTIFACT ---------------------------------------------------------------------
# NOTE: A host layer may have set ARTIFACT
ARTIFACT ?= a.out
ifeq ($(ARTIFACT),)
    $(error [ARTIFACT] Missing value)
endif
ifneq ($(words $(ARTIFACT)),1)
    $(error [ARTIFACT] Value cannot have whitespaces: $(ARTIFACT))
endif
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
# NOTE: Source files must be searched after host layers
ifneq ($(MAKECMDGOALS),deps)
    ifdef SKIPPED_SRC_DIRS
        $(call FN_CHECK_ORIGIN,SKIPPED_SRC_DIRS,file)
    endif

    ifdef SKIPPED_SRC_FILES
        $(call FN_CHECK_ORIGIN,SKIPPED_SRC_FILES,file)
    endif

    ifdef SRC_FILES
        $(call FN_CHECK_ORIGIN,SRC_FILES,file)
    endif

    ifeq ($(SKIP_DEFAULT_SRC_DIR),0)
        ifneq ($(wildcard src),)
            SRC_DIRS := src $(SRC_DIRS)
        endif
    endif

    SRC_DIRS := $(filter-out $(SKIPPED_SRC_DIRS),$(SRC_DIRS))

    # Checks if any SRC_DIR is outside CURDIR
    $(foreach srcDir,$(SRC_DIRS),$(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(srcDir)),,$(error [SRC_DIRS] Invalid directory: $(srcDir))))

    project_mk_src_file_filter := $(subst //,/,$(foreach skippedSrcDir,$(SKIPPED_SRC_DIRS),-and -not -path '$(skippedSrcDir)/*')) -and -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S'

    SRC_FILES := $(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f $(project_mk_src_file_filter) 2> /dev/null)) $(SRC_FILES))

    project_mk_invalid_src_files := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))
    ifneq ($(project_mk_invalid_src_files),)
        $(error [SRC_FILES] Unsupported source file(s): $(project_mk_invalid_src_files))
    endif
endif
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
# NOTE: Include directories must be managed after host layers
ifneq ($(MAKECMDGOALS),deps)
    ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
        ifneq ($(wildcard include),)
            INCLUDE_DIRS := include $(INCLUDE_DIRS)
        endif
    endif

    INCLUDE_DIRS := $(strip $(SRC_DIRS) $(INCLUDE_DIRS))
endif
# ------------------------------------------------------------------------------

# MK_EXTRA_INCLUDES ----------------------------------------------------------------
ifneq ($(MK_EXTRA_INCLUDES),)
    $(call FN_CHECK_ORIGIN,MK_EXTRA_INCLUDES,file)
    include $(MK_EXTRA_INCLUDES)
endif
# ------------------------------------------------------------------------------

# MK_EXTRA_EVAL --------------------------------------------------------------------
ifdef MK_EXTRA_EVAL
    $(call FN_CHECK_ORIGIN,MK_EXTRA_EVAL,file)
    $(eval $(MK_EXTRA_EVAL))
endif
# ------------------------------------------------------------------------------

# GCC management ---------------------------------------------------------------
include $(project_mk_self_dir)include/builder.mk
# ------------------------------------------------------------------------------

endif # ifndef project_mk
