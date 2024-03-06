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

# Builder entrypoint makefile

ifndef cpb_builder_mk
cpb_builder_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_builder_mk))include/common.mk
include $(dir $(cpb_builder_mk))include/native.mk

# Reserved variables -----------------------------------------------------------
$(call FN_CHECK_RESERVED,cpb_builder_mk_src_file_filter)
$(call FN_CHECK_RESERVED,cpb_builder_mk_invalid_src_files)
$(call FN_CHECK_RESERVED,cpb_builder_mk_dist_dirs)
$(call FN_CHECK_RESERVED,cpb_builder_mk_dist_files)
$(call FN_CHECK_RESERVED,cpb_builder_mk_fn_dist_adjust_dir_entry)
$(call FN_CHECK_RESERVED,cpb_builder_mk_fn_dist_adjust_file_entry)
$(call FN_CHECK_RESERVED,cpb_builder_mk_dist_deps_template)
$(call FN_CHECK_RESERVED,O_BUILD_DIR)
$(call FN_CHECK_RESERVED,O_DIST_DIR)
# ------------------------------------------------------------------------------

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(CURDIR)),1)
    $(error Current directory ('$(CURDIR)') contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Only one target per make call ------------------------------------------------
ifneq ($(words $(MAKECMDGOALS)),0)
    ifneq ($(words $(MAKECMDGOALS)),1)
        $(error Only one target can be called per time)
    endif
endif
# ------------------------------------------------------------------------------

# Project name -----------------------------------------------------------------
$(call FN_CHECK_NON_EMPTY,PROJ_NAME)
$(call FN_CHECK_ORIGIN,PROJ_NAME,file)
$(call FN_CHECK_NO_WHITESPACE,PROJ_NAME)
# ------------------------------------------------------------------------------

# Project version --------------------------------------------------------------
PROJ_VERSION ?= 0.1.0
$(call FN_CHECK_NON_EMPTY,PROJ_VERSION)
$(call FN_CHECK_ORIGIN,PROJ_VERSION,file)
ifeq ($(call FN_SEMVER_CHECK,$(PROJ_VERSION)),)
    $(error [PROJ_VERSION] Invalid semantic version: $(PROJ_VERSION))
endif
# ------------------------------------------------------------------------------

# Project type -----------------------------------------------------------------
$(call FN_CHECK_NON_EMPTY,PROJ_TYPE)
$(call FN_CHECK_ORIGIN,PROJ_TYPE,file)
$(call FN_CHECK_NO_WHITESPACE,PROJ_TYPE)
$(call FN_CHECK_OPTIONS,PROJ_TYPE,app lib)
# ------------------------------------------------------------------------------

# LIB_NAME (Only for PROJ_TYPE == lib) -----------------------------------------
ifeq ($(PROJ_TYPE),lib)
    LIB_NAME ?= $(PROJ_NAME)$(call FN_SEMVER_MAJOR,$(PROJ_VERSION))
endif
# ------------------------------------------------------------------------------

# Debug / release --------------------------------------------------------------
DEBUG ?= 0
$(call FN_CHECK_NON_EMPTY,DEBUG)
$(call FN_CHECK_NO_WHITESPACE,DEBUG)
$(call FN_CHECK_OPTIONS,DEBUG,0 1)
# ------------------------------------------------------------------------------

# Build sub-directory ----------------------------------------------------------
ifneq ($(BUILD_SUBDIR),)
    $(call FN_CHECK_NO_WHITESPACE,BUILD_SUBDIR)
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(BUILD_SUBDIR)),,$(error [BUILD_SUBDIR] Invalid path: $(BUILD_SUBDIR)))
endif

O_BUILD_DIR := $(O)/build
ifneq ($(BUILD_SUBDIR),)
    O_BUILD_DIR := $(O_BUILD_DIR)/$(BUILD_SUBDIR)
endif
# ------------------------------------------------------------------------------

# Distribution sub-directory ---------------------------------------------------
ifneq ($(DIST_SUBDIR),)
    $(call FN_CHECK_NO_WHITESPACE,DIST_SUBDIR)
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(DIST_SUBDIR)),,$(error [DIST_SUBDIR] Invalid path: $(DIST_SUBDIR)))
endif
O_DIST_DIR := $(O)/dist
ifneq ($(DIST_SUBDIR),)
    O_DIST_DIR := $(O_DIST_DIR)/$(DIST_SUBDIR)
endif
# ------------------------------------------------------------------------------

# Default include & source directories -----------------------------------------
ifdef SRC_DIRS
    $(call FN_CHECK_ORIGIN,SRC_DIRS,file)
else
    ifneq ($(wildcard src),)
        SRC_DIRS := src
    endif
endif
ifdef INCLUDE_DIRS
    $(call FN_CHECK_ORIGIN,INCLUDE_DIRS,file)
else
    ifneq ($(wildcard include),)
        INCLUDE_DIRS := include
        ifeq ($(PROJ_TYPE),lib)
            DIST_DIRS += include
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Process host layers ----------------------------------------------------------
include $(dir $(cpb_builder_mk))include/hosts.mk
# ------------------------------------------------------------------------------

# LIB_TYPE ---------------------------------------------------------------------
# NOTE: A host layer may have set LIB_TYPE
LIB_TYPE ?= static
$(call FN_CHECK_NON_EMPTY,LIB_TYPE)
$(call FN_CHECK_OPTIONS,LIB_TYPE,shared static)
# ------------------------------------------------------------------------------

# ARTIFACT ---------------------------------------------------------------------
# NOTE: A host layer may have set ARTIFACT
ARTIFACT ?= a.out
$(call FN_CHECK_NON_EMPTY,ARTIFACT)
$(call FN_CHECK_NO_WHITESPACE,ARTIFACT)
# ------------------------------------------------------------------------------

# Skips directory inspection to get file lists ---------------------------------
SKIP_DIR_INSPECTION ?= 0
$(call FN_CHECK_NON_EMPTY,SKIP_DIR_INSPECTION)
$(call FN_CHECK_OPTIONS,SKIP_DIR_INSPECTION,0 1)
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
# NOTE: A host layer could have added source directories.
ifdef SKIPPED_SRC_DIRS
    $(call FN_CHECK_ORIGIN,SKIPPED_SRC_DIRS,file)
endif

ifdef SKIPPED_SRC_FILES
    $(call FN_CHECK_ORIGIN,SKIPPED_SRC_FILES,file)
endif

ifdef SRC_FILES
    $(call FN_CHECK_ORIGIN,SRC_FILES,file)
endif

SRC_DIRS := $(filter-out $(SKIPPED_SRC_DIRS),$(SRC_DIRS))

# Checks if any SRC_DIR is outside CURDIR
$(foreach srcDir,$(SRC_DIRS),$(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(srcDir)),,$(error [SRC_DIRS] Invalid directory: $(srcDir))))

cpb_builder_mk_src_file_filter := $(subst //,/,$(foreach skippedSrcDir,$(SKIPPED_SRC_DIRS),-and -not -path '$(skippedSrcDir)/*')) -and -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S'

ifeq ($(SKIP_DIR_INSPECTION),0)
    SRC_FILES := $(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(call FN_SHELL,find $(srcDir) -type f $(cpb_builder_mk_src_file_filter) 2> /dev/null)) $(SRC_FILES))
endif

cpb_builder_mk_invalid_src_files := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))
ifneq ($(cpb_builder_mk_invalid_src_files),)
    $(error [SRC_FILES] Unsupported source file(s): $(cpb_builder_mk_invalid_src_files))
endif
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
# NOTE: A host layer could have added directories.
INCLUDE_DIRS := $(strip $(SRC_DIRS) $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# POST_INCLUDES ----------------------------------------------------------------
ifneq ($(POST_INCLUDES),)
    $(call FN_CHECK_ORIGIN,POST_INCLUDES,file)
    include $(POST_INCLUDES)
endif
# ------------------------------------------------------------------------------

# POST_EVAL --------------------------------------------------------------------
ifdef POST_EVAL
    $(call FN_CHECK_ORIGIN,POST_EVAL,file)
    $(eval $(POST_EVAL))
endif
# ------------------------------------------------------------------------------

# Process toolchain layers -----------------------------------------------------
include $(dir $(cpb_builder_mk))include/toolchains.mk
# ------------------------------------------------------------------------------

.NOTPARALLEL:

# all (default) ================================================================
.DEFAULT_GOAL := all

.PHONY: all
all: dist ;
# ==============================================================================

# print-vars ===================================================================
VARS += O PROJ_NAME PROJ_VERSION PROJ_TYPE LIB_NAME DEBUG BUILD_SUBDIR O_BUILD_DIR DIST_SUBDIR O_DIST_DIR SRC_DIRS NATIVE_OS NATIVE_ARCH NATIVE_HOST HOST HOSTS_DIRS LIB_TYPE ARTIFACT SKIPPED_SRC_DIRS SKIPPED_SRC_FILES SRC_FILES INCLUDE_DIRS POST_INCLUDES POST_EVAL PRE_CLEAN_DEPS POST_CLEAN_DEPS PRE_BUILD_DEPS POST_BUILD_DEPS DIST_MARKER DIST_DIRS DIST_FILES PRE_DIST_DEPS POST_DIST_DEPS TOOLCHAIN TOOLCHAIN_DIRS
VARS ?= $(sort $(DEFAULT_VAR_SET))
$(call FN_CHECK_NON_EMPTY,VARS)

.PHONY: print-vars
print-vars:
	$(foreach varName,$(VARS),$(info $(varName) = $($(varName))))
	@printf ''
# ==============================================================================

# clean ========================================================================
ifdef PRE_CLEAN_DEPS
    $(call FN_CHECK_ORIGIN,PRE_CLEAN_DEPS,file)
endif
ifdef POST_CLEAN_DEPS
    $(call FN_CHECK_ORIGIN,POST_CLEAN_DEPS,file)
endif

.PHONY: --cpb_builder_mk_pre_clean
--cpb_builder_mk_pre_clean: $(PRE_CLEAN_DEPS) ;

.PHONY: --cpb_builder_mk_clean
--cpb_builder_mk_clean: --cpb_builder_mk_pre_clean
	$(VERBOSE)rm -rf $(O)

.PHONY: --cpb_builder_mk_post_clean
--cpb_builder_mk_post_clean: --cpb_builder_mk_clean $(POST_CLEAN_DEPS) ;

.PHONY: clean
clean: --cpb_builder_mk_post_clean ;
# ==============================================================================

# build ========================================================================
ifdef PRE_BUILD_DEPS
    $(call FN_CHECK_ORIGIN,PRE_BUILD_DEPS,file)
endif
ifdef BUILD_DEPS
    $(call FN_CHECK_ORIGIN,BUILD_DEPS,file)
endif
ifdef POST_BUILD_DEPS
    $(call FN_CHECK_ORIGIN,POST_BUILD_DEPS,file)
endif

.PHONY: --cpb_builder_mk_pre_build
--cpb_builder_mk_pre_build: $(PRE_BUILD_DEPS) ;

.PHONY: --cpb_builder_mk_build
--cpb_builder_mk_build: --cpb_builder_mk_pre_build $(BUILD_DEPS) ;

.PHONY: --cpb_builder_mk_post_build
--cpb_builder_mk_post_build: --cpb_builder_mk_build $(POST_BUILD_DEPS) ;

.PHONY: build
build: --cpb_builder_mk_post_build ;
# ==============================================================================

# dist =========================================================================
ifneq ($(DIST_MARKER),)
    $(call FN_CHECK_NO_WHITESPACE,DIST_MARKER)
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(DIST_MARKER)),,$(error [DIST_MARKER] Invalid path: $(DIST_MARKER)))
endif
ifdef DIST_DIRS
    $(call FN_CHECK_ORIGIN,DIST_DIRS,file)
endif

cpb_builder_mk_dist_dirs := $(DIST_DIRS)

ifdef DIST_FILES
    $(call FN_CHECK_ORIGIN,DIST_FILES,file)
endif
ifneq ($(SRC_FILES),)
    ifeq ($(PROJ_TYPE),app)
        cpb_builder_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):bin/$(ARTIFACT)
    else ifeq ($(PROJ_TYPE),lib)
        cpb_builder_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):lib/$(ARTIFACT)
    endif
endif
cpb_builder_mk_dist_files := $(cpb_builder_mk_dist_files) $(DIST_FILES)

# Each entry (either DIST_DIR or DIST_FILE) has the syntax: src:destPathInDistDir

# Autixiliary function to adjust a distribution directory entry in DIST_DIRS.
# Syntax: $(call cpb_builder_mk_fn_dist_adjust_dir_entry,distDirEntry)
cpb_builder_mk_fn_dist_adjust_dir_entry = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):$(1))

# Autixiliary function to adjust a distribution file entry in DIST_FILES.
# Syntax: $(call cpb_builder_mk_fn_dist_adjust_file_entry,distFileEntry)
cpb_builder_mk_fn_dist_adjust_file_entry = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):$(notdir $(1)))

cpb_builder_mk_dist_dirs := $(foreach distDirEntry,$(cpb_builder_mk_dist_dirs),$(call cpb_builder_mk_fn_dist_adjust_dir_entry,$(distDirEntry)))

DIST_DIRS := $(cpb_builder_mk_dist_dirs)

ifeq ($(SKIP_DIR_INSPECTION),0)
    cpb_builder_mk_dist_files := $(cpb_builder_mk_dist_files) $(foreach distDirEntry,$(cpb_builder_mk_dist_dirs),$(foreach distFile,$(call FN_FIND_FILES,$(call FN_TOKEN,$(distDirEntry),:,1)),$(call FN_TOKEN,$(distDirEntry),:,1)/$(distFile):$(if $(call FN_TOKEN,$(distDirEntry),:,2),$(call FN_TOKEN,$(distDirEntry),:,2)/,)$(distFile)))
endif
cpb_builder_mk_dist_files := $(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(call cpb_builder_mk_fn_dist_adjust_file_entry,$(distFileEntry)))
cpb_builder_mk_dist_files := $(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(call FN_TOKEN,$(distFileEntry),:,1):$(O_DIST_DIR)/$(call FN_TOKEN,$(distFileEntry),:,2))

DIST_FILES := $(cpb_builder_mk_dist_files)

# Template for distribution artifacts targets
# $(call cpb_builder_mk_dist_deps_template,src,dest)
define cpb_builder_mk_dist_deps_template
cpb_builder_mk_dist_deps += $(2)

$(2): $(1)
	$$(call FN_LOG_INFO,$$(V),[DIST] $$@)
	@mkdir -p $$(dir $$@)
	$(VERBOSE)/bin/cp $$< $$@
endef

$(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(eval $(call cpb_builder_mk_dist_deps_template,$(call FN_TOKEN,$(distFileEntry),:,1),$(call FN_TOKEN,$(distFileEntry),:,2))))

ifdef PRE_DIST_DEPS
    $(call FN_CHECK_ORIGIN,PRE_DIST_DEPS,file)
endif
ifdef POST_DIST_DEPS
    $(call FN_CHECK_ORIGIN,POST_DIST_DEPS,file)
endif

--cpb_builder_mk_pre_dist: build $(PRE_DIST_DEPS) ;

ifneq ($(DIST_MARKER),)
    $(O)/$(DIST_MARKER): $(cpb_builder_mk_dist_deps)
	    @touch $@

    .PHONY: --cpb_builder_mk_dist
    --cpb_builder_mk_dist: --cpb_builder_mk_pre_dist $(O)/$(DIST_MARKER) ;
else
    .PHONY: --cpb_builder_mk_dist
    --cpb_builder_mk_dist: --cpb_builder_mk_pre_dist $(cpb_builder_mk_dist_deps) ;
endif

.PHONY: --cpb_builder_mk_post_dist
--cpb_builder_mk_post_dist: --cpb_builder_mk_dist $(POST_DIST_DEPS) ;

.PHONY: dist
dist: --cpb_builder_mk_post_dist ;
# ==============================================================================

endif # ifndef cpb_builder_mk
