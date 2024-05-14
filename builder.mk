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

include $(dir $(cpb_builder_mk))functions.mk
include $(dir $(cpb_builder_mk))include/common.mk

# Reserved variables -----------------------------------------------------------
$(call fn_check_reserved,cpb_builder_mk_src_file_filter)
$(call fn_check_reserved,cpb_builder_mk_invalid_src_files)
$(call fn_check_reserved,cpb_builder_mk_dist_dirs)
$(call fn_check_reserved,cpb_builder_mk_dist_files)
$(call fn_check_reserved,cpb_builder_mk_fn_dist_adjust_dir_entry)
$(call fn_check_reserved,cpb_builder_mk_fn_dist_adjust_file_entry)
$(call fn_check_reserved,cpb_builder_mk_dist_deps_template)
$(call fn_check_reserved,O_BUILD_DIR)
$(call fn_check_reserved,O_DIST_DIR)
# ------------------------------------------------------------------------------

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(CURDIR)),1)
    $(call fn_error,Current directory ('$(CURDIR)') contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Project name -----------------------------------------------------------------
$(call fn_check_not_empty,PROJ_NAME)
$(call fn_check_origin,PROJ_NAME,file)
$(call fn_check_no_whitespace,PROJ_NAME)
# ------------------------------------------------------------------------------

# Project type -----------------------------------------------------------------
$(call fn_check_not_empty,PROJ_TYPE)
$(call fn_check_origin,PROJ_TYPE,file)
$(call fn_check_no_whitespace,PROJ_TYPE)
$(call fn_check_options,PROJ_TYPE,app lib custom)
# ------------------------------------------------------------------------------

# Project version --------------------------------------------------------------
ifdef PROJ_VERSION
    $(call fn_check_not_empty,PROJ_VERSION)
    $(call fn_check_origin,PROJ_VERSION,file)
    PROJ_VERSION := $(call fn_semver,$(PROJ_VERSION),[PROJ_VERSION] Invalid value: $(PROJ_VERSION))
endif
# ------------------------------------------------------------------------------

# LIB_NAME (Only for PROJ_TYPE == lib) -----------------------------------------
ifeq ($(PROJ_TYPE),lib)
    ifneq ($(PROJ_VERSION),)
        LIB_NAME ?= $(PROJ_NAME)$(call fn_semver_major,$(PROJ_VERSION))
    else
        LIB_NAME ?= $(PROJ_NAME)
    endif
    $(call fn_check_not_empty,LIB_NAME)
    $(call fn_check_origin,LIB_NAME,file)
    $(call fn_check_no_whitespace,LIB_NAME)
endif
# ------------------------------------------------------------------------------

# Build sub-directory ----------------------------------------------------------
ifneq ($(BUILD_SUBDIR),)
    $(call fn_check_no_whitespace,BUILD_SUBDIR)
    $(if $(call fn_is_inside_dir,$(CURDIR),$(BUILD_SUBDIR)),,$(call fn_error,[BUILD_SUBDIR] Invalid path: $(BUILD_SUBDIR)))
endif

O_BUILD_DIR := $(O)/build
ifneq ($(BUILD_SUBDIR),)
    O_BUILD_DIR := $(O_BUILD_DIR)/$(BUILD_SUBDIR)
endif
# ------------------------------------------------------------------------------

# Distribution sub-directory ---------------------------------------------------
ifneq ($(DIST_SUBDIR),)
    $(call fn_check_no_whitespace,DIST_SUBDIR)
    $(if $(call fn_is_inside_dir,$(CURDIR),$(DIST_SUBDIR)),,$(call fn_error,[DIST_SUBDIR] Invalid path: $(DIST_SUBDIR)))
endif
O_DIST_DIR := $(O)/dist
ifneq ($(DIST_SUBDIR),)
    O_DIST_DIR := $(O_DIST_DIR)/$(DIST_SUBDIR)
endif
# ------------------------------------------------------------------------------

# Default include & source directories -----------------------------------------
ifneq ($(PROJ_TYPE),custom)
ifdef SRC_DIRS
    $(call fn_check_origin,SRC_DIRS,file)
else ifdef SRC_FILES
    $(call fn_check_origin,SRC_FILES,file)
else
    ifneq ($(wildcard src),)
        SRC_DIRS := src
    endif
endif
ifdef INCLUDE_DIRS
    $(call fn_check_origin,INCLUDE_DIRS,file)
else
    ifneq ($(wildcard include),)
        INCLUDE_DIRS := include
        ifeq ($(PROJ_TYPE),lib)
            DIST_DIRS += include
        endif
    endif
endif
endif #ifneq ($(PROJ_TYPE),custom)
# ------------------------------------------------------------------------------

# Process host layers ----------------------------------------------------------
include $(dir $(cpb_builder_mk))include/hosts.mk
# ------------------------------------------------------------------------------

# LIB_TYPE ---------------------------------------------------------------------
# NOTE: A host layer may have set LIB_TYPE
LIB_TYPE ?= static
$(call fn_check_not_empty,LIB_TYPE)
$(call fn_check_options,LIB_TYPE,shared static)
# ------------------------------------------------------------------------------

# ARTIFACT ---------------------------------------------------------------------
# NOTE: A host layer may have set ARTIFACT
ARTIFACT ?= a.out
$(call fn_check_not_empty,ARTIFACT)
$(call fn_check_no_whitespace,ARTIFACT)

ifneq ($(findstring /,$(ARTIFACT)),)
    $(call fn_error,[ARTIFACT] Value cannot have path components: "$(ARTIFACT)")
endif
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
# NOTE: A host layer could have added source directories.
ifdef SKIPPED_SRC_DIRS
    $(call fn_check_origin,SKIPPED_SRC_DIRS,file)
endif

ifdef SKIPPED_SRC_FILES
    $(call fn_check_origin,SKIPPED_SRC_FILES,file)
endif

# Checks if a entry was added to included and skipped at the same time
ifneq ($(filter $(SKIPPED_SRC_DIRS),$(SRC_DIRS)),)
    $(call fn_error,[SRC_DIRS][SKIPPED_SRC_DIRS] Value(s) present on both variables: $(filter $(SKIPPED_SRC_DIRS),$(SRC_DIRS)))
endif

# Checks if a entry was added to included and skipped at the same time
ifneq ($(filter $(SKIPPED_SRC_FILES),$(SRC_FILES)),)
    $(call fn_error,[SRC_FILES][SKIPPED_SRC_FILES] Value(s) present on both variables: $(filter $(SKIPPED_SRC_FILES),$(SRC_FILES)))
endif

SRC_DIRS := $(filter-out $(SKIPPED_SRC_DIRS),$(SRC_DIRS))

# NOTE: A second filter-out is required due to files contained in SRC_DIRS
SRC_FILES := $(filter-out $(SKIPPED_SRC_FILES),$(SRC_FILES))

$(foreach srcDir,$(SRC_DIRS),$(if $(wildcard $(srcDir)),$(if $(call fn_is_inside_dir,$(CURDIR),$(srcDir)),,$(call fn_error,[SRC_DIRS] Directory outside project root directory: '$(srcDir)')),$(call fn_error,[SRC_DIRS] No such directory: '$(srcDir)')))
$(foreach srcFile,$(SRC_FILES),$(if $(wildcard $(srcFile)),$(if $(call fn_is_inside_dir,$(CURDIR),$(dir $(srcFile))),,$(call fn_error,[SRC_FILES] File outside project root directory: '$(srcFile)')),$(call fn_error,[SRC_FILES] No such file: '$(srcFile)')))

# Checks if any SRC_DIR or SRC_FILE is outside CURDIR
cpb_builder_mk_src_file_filter := $(subst //,/,$(foreach skippedSrcDir,$(SKIPPED_SRC_DIRS),-and -not -path '$(skippedSrcDir)/*')) -and -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S'

# Second filter-out
SRC_FILES := $(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(call fn_shell,find $(srcDir) -type f $(cpb_builder_mk_src_file_filter) 2> /dev/null)) $(SRC_FILES))

cpb_builder_mk_invalid_src_files := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))

ifneq ($(cpb_builder_mk_invalid_src_files),)
    $(call fn_error,[SRC_FILES] Unsupported source file(s): $(cpb_builder_mk_invalid_src_files))
endif
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
# NOTE: A host layer could have added directories.
INCLUDE_DIRS := $(strip $(SRC_DIRS) $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# POST_INCLUDES ----------------------------------------------------------------
ifneq ($(POST_INCLUDES),)
    $(call fn_check_origin,POST_INCLUDES,file)
    include $(POST_INCLUDES)
endif
# ------------------------------------------------------------------------------

# POST_EVAL --------------------------------------------------------------------
ifdef POST_EVAL
    $(call fn_check_origin,POST_EVAL,file)
    $(eval $(POST_EVAL))
endif
# ------------------------------------------------------------------------------

# Toolchain management ---------------------------------------------------------
include $(dir $(cpb_builder_mk))include/toolchain.mk
# ------------------------------------------------------------------------------

# all (default) ================================================================
.DEFAULT_GOAL := all

.PHONY: all
all: dist ;
# ==============================================================================

# print-vars ===================================================================
VARS += PROJ_NAME PROJ_TYPE PROJ_VERSION LIB_NAME BUILD_SUBDIR O_BUILD_DIR DIST_SUBDIR O_DIST_DIR SRC_DIRS HOSTS_DIRS LIB_TYPE ARTIFACT SKIPPED_SRC_DIRS SKIPPED_SRC_FILES SRC_FILES INCLUDE_DIRS POST_INCLUDES POST_EVAL PRE_CLEAN_DEPS POST_CLEAN_DEPS PRE_CLEAN_ALL_DEPS POST_CLEAN_ALL_DEPS PRE_BUILD_DEPS BUILD_DEPS POST_BUILD_DEPS DIST_MARKER DIST_DIRS DIST_FILES PRE_DIST_DEPS POST_DIST_DEPS
override VARS := $(sort $(VARS))
$(call fn_check_not_empty,VARS)

.PHONY: print-vars
print-vars:
	$(foreach varName,$(VARS),$(info $(varName) = $($(varName))))
	@printf ''
# ==============================================================================

# clean & clean-all ============================================================
# clean ------------------------------------------------------------------------
ifdef PRE_CLEAN_DEPS
    $(call fn_check_origin,PRE_CLEAN_DEPS,file)
endif
ifdef POST_CLEAN_DEPS
    $(call fn_check_origin,POST_CLEAN_DEPS,file)
endif
.PHONY: --cpb_builder_mk_pre_clean
--cpb_builder_mk_pre_clean: $(PRE_CLEAN_DEPS) ;

.PHONY: --cpb_builder_mk_clean
--cpb_builder_mk_clean: --cpb_builder_mk_pre_clean
	$(V_PREFIX)rm -rf $(O)
	$(V_PREFIX)[ -d $(O_BASE) ] && rmdir --ignore-fail-on-non-empty $(O_BASE)/* > /dev/null 2>&1|| true
	$(V_PREFIX)[ -d $(O_BASE) ] && rmdir --ignore-fail-on-non-empty $(O_BASE) || true

.PHONY: --cpb_builder_mk_post_clean
--cpb_builder_mk_post_clean: --cpb_builder_mk_clean $(POST_CLEAN_DEPS) ;

.PHONY: clean
clean: --cpb_builder_mk_post_clean ;
# ------------------------------------------------------------------------------
# clean-all --------------------------------------------------------------------
ifdef PRE_CLEAN_ALL_DEPS
    $(call fn_check_origin,PRE_CLEAN_ALL_DEPS,file)
endif
ifdef POST_CLEAN_ALL_DEPS
    $(call fn_check_origin,POST_CLEAN_ALL_DEPS,file)
endif
.PHONY: --cpb_builder_mk_pre_clean_all
--cpb_builder_mk_pre_clean_all: $(PRE_CLEAN_ALL_DEPS) ;

.PHONY: --cpb_builder_mk_clean_all
--cpb_builder_mk_clean_all: --cpb_builder_mk_pre_clean_all
	$(V_PREFIX) rm -rf $(O_BASE)

.PHONY: --cpb_builder_mk_post_clean_all
--cpb_builder_mk_post_clean_all: --cpb_builder_mk_clean_all $(POST_CLEAN_ALL_DEPS) ;

.PHONY: clean-all
clean-all: --cpb_builder_mk_post_clean_all ;
# ------------------------------------------------------------------------------
# ==============================================================================

# build ========================================================================
ifdef PRE_BUILD_DEPS
    $(call fn_check_origin,PRE_BUILD_DEPS,file)
endif
ifdef BUILD_DEPS
    $(call fn_check_origin,BUILD_DEPS,file)
endif
ifdef POST_BUILD_DEPS
    $(call fn_check_origin,POST_BUILD_DEPS,file)
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
    $(call fn_check_no_whitespace,DIST_MARKER)
    $(if $(call fn_is_inside_dir,$(CURDIR),$(DIST_MARKER)),,$(call fn_error,[DIST_MARKER] Invalid path: '$(DIST_MARKER)'))
endif
ifdef DIST_DIRS
    $(call fn_check_origin,DIST_DIRS,file)
endif

cpb_builder_mk_dist_dirs := $(DIST_DIRS)

ifdef DIST_FILES
    $(call fn_check_origin,DIST_FILES,file)
endif
ifneq ($(SRC_FILES),)
    ifeq ($(PROJ_TYPE),app)
        cpb_builder_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):bin/$(ARTIFACT)
    else ifeq ($(PROJ_TYPE),lib)
        cpb_builder_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):lib/$(ARTIFACT)
    endif
endif
cpb_builder_mk_dist_files := $(DIST_FILES) $(cpb_builder_mk_dist_files)

# Each entry (either DIST_DIR or DIST_FILE) has the syntax: src:destPathInDistDir

# Auxiliary function to adjust a distribution directory entry in DIST_DIRS.
# Syntax: $(call cpb_builder_mk_fn_dist_adjust_dir_entry,distDirEntry)
cpb_builder_mk_fn_dist_adjust_dir_entry = $(if $(call fn_token,$(1),:,2),$(1),$(1):$(1))

# Auxiliary function to adjust a distribution file entry in DIST_FILES.
# Syntax: $(call cpb_builder_mk_fn_dist_adjust_file_entry,distFileEntry)
cpb_builder_mk_fn_dist_adjust_file_entry = $(if $(call fn_token,$(1),:,2),$(1),$(1):$(notdir $(1)))

cpb_builder_mk_dist_dirs := $(foreach distDirEntry,$(cpb_builder_mk_dist_dirs),$(call cpb_builder_mk_fn_dist_adjust_dir_entry,$(distDirEntry)))

DIST_DIRS := $(cpb_builder_mk_dist_dirs)

cpb_builder_mk_dist_files := $(cpb_builder_mk_dist_files) $(foreach distDirEntry,$(cpb_builder_mk_dist_dirs),$(foreach distFile,$(call fn_find_files,$(call fn_token,$(distDirEntry),:,1)),$(call fn_token,$(distDirEntry),:,1)/$(distFile):$(if $(call fn_token,$(distDirEntry),:,2),$(call fn_token,$(distDirEntry),:,2)/,)$(distFile)))
cpb_builder_mk_dist_files := $(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(call cpb_builder_mk_fn_dist_adjust_file_entry,$(distFileEntry)))
cpb_builder_mk_dist_files := $(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(call fn_token,$(distFileEntry),:,1):$(O_DIST_DIR)/$(call fn_token,$(distFileEntry),:,2))

DIST_FILES := $(cpb_builder_mk_dist_files)

# Template for distribution artifacts targets
# $(call cpb_builder_mk_dist_deps_template,src,dest)
define cpb_builder_mk_dist_deps_template
cpb_builder_mk_dist_deps += $(2)

$(2): $(1)
	$$(call fn_log_cmd,$$(V),[DIST] $$@)
	@mkdir -p $$(dir $$@)
	$(V_PREFIX)ln -f $$< $$@
endef

$(foreach distFileEntry,$(cpb_builder_mk_dist_files),$(eval $(call cpb_builder_mk_dist_deps_template,$(call fn_token,$(distFileEntry),:,1),$(call fn_token,$(distFileEntry),:,2))))

ifdef PRE_DIST_DEPS
    $(call fn_check_origin,PRE_DIST_DEPS,file)
endif
ifdef POST_DIST_DEPS
    $(call fn_check_origin,POST_DIST_DEPS,file)
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
