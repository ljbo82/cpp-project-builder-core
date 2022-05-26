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

# gcc-project-builder main makefile

ifndef __builder_mk__
__builder_mk__ := 1

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(shell pwd)),1)
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Include auxiliary makefiles --------------------------------------------------
__builder_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__builder_mk_self_dir__)common.mk
include $(__builder_mk_self_dir__)functions.mk
include $(__builder_mk_self_dir__)native-host.mk
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

# Host -------------------------------------------------------------------------
ifndef HOST
    ifdef NATIVE_HOST
        HOST := $(NATIVE_HOST)
    endif
else
    ifeq ($(HOST),)
        $(error [HOST] Missing value)
    else
        ifneq ($(words $(HOST)),1)
           $(error [HOST] Value cannot have whitespaces: $(HOST))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Output directories (read-only vars) ------------------------------------------
__builder_mk_o__ := $(O)/$(if $(HOST),$(HOST),native)
ifeq ($(DEBUG),0)
    __builder_mk_o__ := $(__builder_mk_o__)/release
else
    __builder_mk_o__ := $(__builder_mk_o__)/debug
endif

# Build directory
BUILD_DIR ?= build
ifneq ($(words $(BUILD_DIR)),1)
    $(error [BUILD_DIR] Value cannot have whitespaces: $(BUILD_DIR)
endif
ifeq ($(BUILD_DIR),)
    $(error [BUILD_DIR] Missing value)
endif
ifdef O_BUILD_DIR
    $(error [O_BUILD_DIR] Reserved variable)
endif
O_BUILD_DIR := $(__builder_mk_o__)/$(BUILD_DIR)

# Distribution directory
DIST_DIR ?= dist
ifneq ($(words $(DIST_DIR)),1)
    $(error [DIST_DIR] Value cannot have whitespaces: $(DIST_DIR)
endif
ifeq ($(DIST_DIR),)
    $(error [DIST_DIR] Missing value)
endif
ifdef O_DIST_DIR
    $(error [O_DIST_DIR] Reserved variable)
endif
O_DIST_DIR := $(__builder_mk_o__)/$(DIST_DIR)
# ------------------------------------------------------------------------------

# Loads host definitions -------------------------------------------------------

# Precedence:
# 1. project-specific host definitions (from most specific to most generic,
#    for example: linux-arm-v9 > linux-arm > linux)
#
# 2. Build-system-specific host definitions (from most specific to most generic,
#    for example: linux-arm > linux)

# Factorizer auxiliary function template.
# Syntax: $(call __builder_mk_host_factorizer__,token,delimiter)
define __builder_mk_host_factorizer__
__builder_mk_host_factorizer_current__  := $$(if $$(__builder_mk_host_factorizer_previous__),$$(__builder_mk_host_factorizer_previous__)$(2)$(1),$(1))
__builder_mk_host_factorizer_previous__ := $$(__builder_mk_host_factorizer_current__)
__builder_mk_host_factorizer_factors__  := $$(__builder_mk_host_factorizer_current__) $$(__builder_mk_host_factorizer_factors__)
endef

# Factorizer auxiliary function template for tokenized strings.
# Syntax: $(call __builder_mk_host_factorize__,tokenizedString,delimiter)
__builder_mk_host_factorize__ = $$(foreach token,$$(subst $(2), ,$(1)),$$(eval $$(call __builder_mk_host_factorizer__,$$(token),$(2))))

# Factorizer function for tokenized strings.
# Syntax: $(call __builder_mk_host_factorize__,tokenizedString,delimiter)
__builder_mk_fn_host_factorize__ = $(eval $(call __builder_mk_host_factorize__,$(1),$(2)))$(__builder_mk_host_factorizer_factors__)

# 1. Loads project-specific host definitions
HOSTS_DIR ?= hosts
ifneq ($(origin HOSTS_DIR),file)
    $(error [HOSTS_DIR] Not defined in a makefile (origin: $(origin HOSTS_DIR)))
endif
ifeq ($(HOSTS_DIR),)
    $(error [HOSTS_DIR] Missing value)
endif
ifneq ($(words $(HOSTS_DIR)),1)
    $(error [HOSTS_DIR] Value cannot have whitespaces: $(HOSTS_DIR))
endif

HOST_MK ?= host.mk
ifneq ($(origin HOST_MK),file)
    $(error [HOST_MK] Not defined in a makefile (origin: $(origin HOST_MK)))
endif
ifeq ($(HOST_MK),)
    $(error [HOST_MK] Missing value)
endif
ifneq ($(words $(HOST_MK)),1)
    $(error [HOST_MK] Value cannot have whitespaces: $(HOST_MK))
endif

# Autixiliary function to add a project-specific host definitions.
# Syntax: $(call __builder_mk_project_host_token__,hostToken)
define __builder_mk_project_host_token__
__builder_mk_project_host_token_src_dirs__ += $(if $(wildcard $(HOSTS_DIR)/$(1)/src),$(HOSTS_DIR)/$(1)/src,)
__builder_mk_project_host_mk_includes__    += $(if $(wildcard $(HOSTS_DIR)/$(1)/$(HOST_MK)),$(HOSTS_DIR)/$(1)/$(HOST_MK),)
endef

$(foreach hostToken,$(call __builder_mk_fn_host_factorize__,$(HOST),-),$(eval $(call __builder_mk_project_host_token__,$(hostToken))))

__builder_mk_project_host_token_src_dirs__ := $(__builder_mk_project_host_token_src_dirs__)
__builder_mk_project_host_mk_includes__    := $(__builder_mk_project_host_mk_includes__)

ifneq ($(__builder_mk_project_host_token_src_dirs__),)
    __builder_mk_src_dirs__ := $(__builder_mk_project_host_token_src_dirs__)
endif

ifneq ($(__builder_mk_project_host_mk_includes__),)
    include $(__builder_mk_project_host_mk_includes__)
endif

# 2. Loads standard (build-system) host definitions

# Autixiliary template to add a standard host definitions makefile.
# Syntax: $(call __builder_mk_std_host_includes__,hostToken)
__builder_mk_std_host_includes__ = $(if $(wildcard $(__builder_mk_self_dir__)hosts/$(1).mk),$(__builder_mk_self_dir__)hosts/$(1).mk,)
__builder_mk_std_host_includes__ := $(strip $(foreach hostToken,$(call __builder_mk_fn_host_factorize__,$(HOST),-),$(call __builder_mk_std_host_includes__,$(hostToken))))

ifneq ($(__builder_mk_std_host_includes__),)
    include $(__builder_mk_std_host_includes__)
endif
# ------------------------------------------------------------------------------

# LIB_TYPE ----------------------------------------------------------------------

# NOTE: host may have set a default LIB_TYPE

ifeq ($(PROJ_TYPE),lib)
    LIB_TYPE ?= shared
    ifeq ($(LIB_TYPE),)
        $(error [LIB_TYPE] Missing value)
    endif
    ifneq ($(words $(LIB_TYPE)),1)
        $(error [LIB_TYPE] Value cannot have whitespaces: $(LIB_TYPE))
    endif
    ifneq ($(LIB_TYPE),shared)
        ifneq ($(LIB_TYPE),static)
            $(error [LIB_TYPE] Invalid value: $(LIB_TYPE))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# TARGET -----------------------------------------------------------------------

# NOTE: host may have set a default TARGET

TARGET ?= a.out
ifeq ($(TARGET),)
    $(error [TARGET] Missing value)
endif
ifneq ($(words $(TARGET)),1)
    $(error [TARGET] Value cannot have whitespaces: $(TARGET))
endif
# ------------------------------------------------------------------------------

# Source directories -----------------------------------------------------------
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
        __builder_mk_src_dirs__ := $(__builder_mk_src_dirs__) src
    endif
endif

__builder_mk_src_dirs__ := $(call FN_UNIQUE,$(__builder_mk_src_dirs__) $(SRC_DIRS))
SRC_DIRS := $(__builder_mk_src_dirs__)
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
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

__builder_mk_include_dirs__ := $(__builder_mk_src_dirs__)
ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
    ifneq ($(wildcard include),)
        __builder_mk_include_dirs__ := $(__builder_mk_include_dirs__) include
    endif
endif

# NOTE: LIBS may add entries to INCLUDE_DIRS

__builder_mk_include_dirs__ := $(__builder_mk_include_dirs__) $(INCLUDE_DIRS)
# ------------------------------------------------------------------------------

# LIBS -------------------------------------------------------------------------
ifdef LIBS
    ifneq ($(origin LIBS),file)
        $(error [LIBS] Not defined in a makefile (origin: $(origin LIBS)))
    endif
endif

__builder_mk_libs__ := $(call FN_UNIQUE,$(LIBS))

# NOTE: LIBS entries' syntax: libname[:libDir[:includeDirs]]

define __builder_mk_libs_parse_entry__
__builder_mk_libs_parse_entry_ld_libs__      := $(if $(findstring :,$(1)),$$(call FN_TOKEN,$(1),:,1),$(1)) $$(__builder_mk_libs_parse_entry_ld_libs__)
__builder_mk_libs_parse_entry_lib_dirs__     := $$(call FN_TOKEN,$(1),:,2) $$(__builder_mk_libs_parse_entry_lib_dirs__)
__builder_mk_libs_parse_entry_lib_includes__ := $$(call FN_TOKEN,$(1),:,3-) $$(__builder_mk_libs_parse_entry_lib_includes__)
endef

define __builder_mk_libs_parse_entries__
$$(foreach libEntry,$(1),$$(eval $$(call __builder_mk_libs_parse_entry__,$$(libEntry))))
__builder_mk_libs_parse_entry_ld_libs__ := $$(call FN_UNIQUE,$$(__builder_mk_libs_parse_entry_ld_libs__))
__builder_mk_libs_parse_entry_lib_dirs__ := $$(call FN_UNIQUE,$$(__builder_mk_libs_parse_entry_lib_dirs__))
__builder_mk_libs_parse_entry_lib_includes__ := $$(call FN_UNIQUE,$$(__builder_mk_libs_parse_entry_lib_includes__))
endef

$(eval $(call __builder_mk_libs_parse_entries__,$(__builder_mk_libs__)))

__builder_mk_include_dirs__ := $(__builder_mk_include_dirs__) $(__builder_mk_libs_parse_entry_lib_includes__)

INCLUDE_DIRS := $(call FN_UNIQUE,$(__builder_mk_include_dirs__))

LDFLAGS := $(foreach libDir,$(__builder_mk_libs_parse_entry_lib_dirs__),-L$(libDir)) $(foreach lib,$(__builder_mk_libs_parse_entry_ld_libs__),-l$(lib)) $(LDFLAGS)
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
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
SRC_FILES := $(call FN_UNIQUE,$(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S' 2> /dev/null)) $(SRC_FILES)))

__builder_mk_invalid_src_files__ := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))
ifneq ($(__builder_mk_invalid_src_files__),)
    $(error [SRC_FILES] Unsupported source file(s): $(__builder_mk_invalid_src_files__))
endif
undefine __builder_mk_invalid_src_files__
# ------------------------------------------------------------------------------

# Strips release build ---------------------------------------------------------
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
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
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
# ------------------------------------------------------------------------------

# Compiler management ----------------------------------------------------------

# AS
ifndef AS
    AS := as
else
    __builder_mk_origin_as__ := $(origin AS)
    ifeq ($(__builder_mk_origin_as__),default)
        AS := as
    else ifeq ($(AS),)
        $(error [AS] Missing value)
    endif
endif

# AR
ifndef AR
    AR := ar
else
    __builder_mk_origin_ar__ := $(origin AR)
    ifeq ($(__builder_mk_origin_ar__),default)
        AR := ar
    else ifeq ($(AR),)
        $(error [AR] Missing value)
    endif
endif

# CC
ifndef CC
    CC := gcc
else
    __builder_mk_origin_cc__ := $(origin CC)
    ifeq ($(__builder_mk_origin_cc__),default)
        CC := gcc
    else ifeq ($(CC),)
        $(error [CC] Missing value)
    endif
endif

# CXX
ifndef CXX
    CXX := g++
else
    __builder_mk_origin_cxx__ := $(origin CXX)
    ifeq ($(__builder_mk_origin_cxx__),default)
        CXX := g++
    else ifeq ($(CXX),)
        $(error [CXX] Missing value)
    endif
endif

# LD
__builder_mk_is_cpp_project__ := $(strip $(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' 2> /dev/null)))
ifeq ($(__builder_mk_is_cpp_project__),)
    __builder_mk_is_cpp_project__ := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null)))
endif

ifeq ($(__builder_mk_is_cpp_project__),)
    # Pure C project
    __builder_mk_ld__ := gcc
else
    # C/C++ project
    __builder_mk_ld__ := g++
endif

ifndef LD
    LD := $(__builder_mk_ld__)
else
    __builder_mk_origin_ld__ := $(origin LD)
    ifeq ($(__builder_mk_origin_ld__),default)
        LD := $(__builder_mk_ld__)
    else ifeq ($(LD),)
        $(error [LD] Missing value)
    endif
endif

__builder_mk_cflags__ += -Wall
__builder_mk_cxxflags__ += -Wall

ifneq ($(DEBUG),0)
    __builder_mk_cflags__ += -g3
    __builder_mk_cxxflags__ += -g3
    __builder_mk_asflags__ += -g3
else
    ifneq ($(OPTIMIZE_RELEASE),0)
        __builder_mk_cflags__ += -O$(RELEASE_OPTIMIZATION_LEVEL)
        __builder_mk_cxxflags__ += -O$(RELEASE_OPTIMIZATION_LEVEL)
    endif

    ifneq ($(STRIP_RELEASE),0)
        __builder_mk_cflags__ += -s
        __builder_mk_cxxflags__ += -s
        __builder_mk_ldflags__ += -s
    endif
endif

ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),shared)
        __builder_mk_cflags__ += -fPIC
        __builder_mk_cxxflags__ += -fPIC
        __builder_mk_ldflags__ += -shared
    endif
endif

__builder_mk_include_flags__ := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

override CFLAGS   := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_cflags__) $(CFLAGS))
override CXXFLAGS := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_cxxflags__) $(CXXFLAGS))
override ASFLAGS  := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_asflags__) $(ASFLAGS))
override LDFLAGS  := $(call FN_UNIQUE, $(__builder_mk_ldflags__) $(LDFLAGS))

undefine __builder_mk_cflags__
undefine __builder_mk_cxxflags__
undefine __builder_mk_asflags__
undefine __builder_mk_ldflags__
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
.DEFAULT_GOAL := all

.NOTPARALLEL:
# ------------------------------------------------------------------------------

# all ==========================================================================
.PHONY: all
all: dist
# ==============================================================================

# print-vars ===================================================================
VARS ?= $(sort DEBUG HOST O V EXTRA_DIST_DIRS EXTRA_DIST_FILES INCLUDE_DIRS LIB_TYPE LIBS POST_BUILD_DEPS POST_CLEAN_DEPS POST_DIST_DEPS PRE_BUILD_DEPS PRE_CLEAN_DEPS PRE_DIST_DEPS PROJ_NAME PROJ_TYPE PROJ_VERSION SRC_DIRS SRC_FILES AR AS ASFLAGS CC CFLAGS CROSS_COMPILE CXX CXXFLAGS LD LDFLAGS O_BUILD_DIR O_DIST_DIR HOST_MK HOSTS_DIR OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL SKIP_DEFAULT_INCLUDE_DIR SKIP_DEFAULT_SRC_DIR SKIPPED_SRC_DIRS SKIPPED_SRC_FILES STRIP_RELEASE TARGET)
.PHONY: print-vars
print-vars:
    ifeq ($(VARS),)
	    $(error [VARS] Missing value)
    endif
	$(foreach varName,$(VARS),$(info $(varName) = $($(varName))))
	@printf ''
# ==============================================================================

# clean ========================================================================
ifdef PRE_CLEAN_DEPS
    ifneq ($(origin PRE_CLEAN_DEPS),file)
        $(error [PRE_CLEAN_DEPS] Not defined in a makefile (origin: $(origin PRE_CLEAN_DEPS)))
    endif
endif
ifdef POST_CLEAN_DEPS
    ifneq ($(origin POST_CLEAN_DEPS),file)
        $(error [POST_CLEAN_DEPS] Not defined in a makefile (origin: $(origin POST_CLEAN_DEPS)))
    endif
endif

.PHONY: pre-clean
pre-clean: $(PRE_CLEAN_DEPS)

--__builder_mk_clean__: pre-clean
	$(O_VERBOSE)rm -rf $(O)

--__builder_mk_post_clean__: --__builder_mk_clean__ $(POST_CLEAN_DEPS)

.PHONY: clean
clean: --__builder_mk_post_clean__
# ==============================================================================

# build ========================================================================
ifdef PRE_BUILD_DEPS
    ifneq ($(origin PRE_BUILD_DEPS),file)
        $(error [PRE_BUILD_DEPS] Not defined in a makefile (origin: $(origin PRE_BUILD_DEPS)))
    endif
endif
ifdef POST_BUILD_DEPS
    ifneq ($(origin POST_BUILD_DEPS),file)
        $(error [POST_BUILD_DEPS] Not defined in a makefile (origin: $(origin POST_BUILD_DEPS)))
    endif
endif
ifneq ($(SRC_FILES),)
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
            __builder_mk_obj_suffix__ := .lo
        else
            __builder_mk_obj_suffix__ := .o
        endif
    else
        __builder_mk_obj_suffix__ := .o
    endif

    __builder_mk_obj_files__ := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(__builder_mk_obj_suffix__))

    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
            __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.lo=.d)
        else
            __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.o=.d)
        endif
    else
        __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.o=.d)
    endif
endif

.PHONY: pre-build
pre-build: $(PRE_BUILD_DEPS)
    ifneq ($(SRC_FILES),)
        ifneq ($(HOST),$(NATIVE_HOST))
            ifeq ($(origin CROSS_COMPILE),undefined)
	            $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
            endif
        endif
    endif

--__builder_mk_build__: $(if $(SRC_FILES),$(O_BUILD_DIR)/$(TARGET),)

--__builder_mk_post_build__: --__builder_mk_build__ $(POST_BUILD_DEPS)

define __builder_mk_build_target__
.PHONY: build
build: --__builder_mk_post_build__
ifneq ($(SRC_FILES),)
$(O_BUILD_DIR)/$(TARGET): pre-build $(__builder_mk_obj_files__)
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
	        @echo [LD] $$@
	        $(O_VERBOSE)$(CROSS_COMPILE)$(LD) $$(strip -o $$@ $(__builder_mk_obj_files__) $(LDFLAGS))
        endif
        ifeq ($(LIB_TYPE),static)
	        @echo [AR] $$@
	        $(O_VERBOSE)$(CROSS_COMPILE)$(AR) rcs $$@ $(__builder_mk_obj_files__)
        endif
    endif
    ifeq ($(PROJ_TYPE),app)
	    @echo [LD] $$@
	    $(O_VERBOSE)$(CROSS_COMPILE)$(LD) $$(strip -o $$@ $(__builder_mk_obj_files__) $(LDFLAGS))
    endif
endif
endef

$(eval $(__builder_mk_build_target__))

# C sources --------------------------------------------------------------------
$(O_BUILD_DIR)/%.c$(__builder_mk_obj_suffix__): %.c
	@echo [CC] $@
	@mkdir -p $(dir $@)
	$(O_VERBOSE)$(CROSS_COMPILE)$(CC) $(strip $(CFLAGS) -c $< -o $@)
# ------------------------------------------------------------------------------

# C++ sources ------------------------------------------------------------------
define __builder_mk_cxx_template__ =
$(O_BUILD_DIR)/%.$(1)$(__builder_mk_obj_suffix__): %.$(1)
	@echo [CXX] $$@
	@mkdir -p $$(dir $$@)
	$(O_VERBOSE)$(CROSS_COMPILE)$(CXX) $$(strip $(CXXFLAGS) -c $$< -o $$@)
endef

$(eval $(call __builder_mk_cxx_template__,cpp))
$(eval $(call __builder_mk_cxx_template__,cxx))
$(eval $(call __builder_mk_cxx_template__,cc))
# ------------------------------------------------------------------------------

# Assembly sources -------------------------------------------------------------
define __builder_mk_as_template__ =
$(O_BUILD_DIR)/%.$(1)$(__builder_mk_obj_suffix__): %.$(1)
	@echo [AS] $$@
	@mkdir -p $$(dir $$@)
	$(O_VERBOSE)$(CROSS_COMPILE)$(AS) $$(strip $(ASFLAGS) -c $$< -o $$@)
endef

$(eval $(call __builder_mk_as_template__,s))
$(eval $(call __builder_mk_as_template__,S))
# ------------------------------------------------------------------------------

-include $(__builder_mk_dep_files__)
# ==============================================================================

# dist =========================================================================
ifdef EXTRA_DIST_DIRS
    ifneq ($(origin EXTRA_DIST_DIRS),file)
        $(error [EXTRA_DIST_DIRS] Not defined in a makefile (origin: $(origin EXTRA_DIST_DIRS)))
    endif
endif
ifeq ($(PROJ_TYPE),lib)
    ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
        ifneq ($(wildcard include),)
            __builder_mk_dist_dirs__ := include:include
        endif
    endif
endif
__builder_mk_dist_dirs__ := $(call FN_UNIQUE,$(__builder_mk_dist_dirs__) $(EXTRA_DIST_DIRS))

ifdef EXTRA_DIST_FILES
    ifneq ($(origin EXTRA_DIST_FILES),file)
        $(error [EXTRA_DIST_FILES] Not defined in a makefile (origin: $(origin EXTRA_DIST_FILES)))
    endif
endif
ifneq ($(SRC_FILES),)
    ifeq ($(PROJ_TYPE),app)
        __builder_mk_dist_files__ := $(O_BUILD_DIR)/$(TARGET):bin/$(TARGET)
    else ifeq ($(PROJ_TYPE),lib)
        __builder_mk_dist_files__ := $(O_BUILD_DIR)/$(TARGET):lib/$(TARGET)
    endif
endif
__builder_mk_dist_files__ := $(call FN_UNIQUE,$(__builder_mk_dist_files__) $(EXTRA_DIST_FILES))

# Each entry (either O_DIST_DIR or DIST_FILE) has the syntax: src:destPathInDistDir

# Autixiliary function to adjust a distribution directory entry in EXTRA_DIST_DIRS.
# Syntax: $(call __builder_mk_fn_dist_adjust_dir_entry__,distDirEntry)
__builder_mk_fn_dist_adjust_dir_entry__ = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):)

# Autixiliary function to adjust a distribution file entry in EXTRA_DIST_FILES.
# Syntax: $(call __builder_mk_fn_dist_adjust_file_entry__,distFileEntry)
__builder_mk_fn_dist_adjust_file_entry__ = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):$(notdir $(1)))

__builder_mk_dist_dirs__ := $(call FN_UNIQUE,$(foreach distDirEntry,$(__builder_mk_dist_dirs__),$(call __builder_mk_fn_dist_adjust_dir_entry__,$(distDirEntry))))

__builder_mk_dist_files__ := $(__builder_mk_dist_files__) $(foreach distDirEntry,$(__builder_mk_dist_dirs__),$(foreach distFile,$(call FN_FIND_FILES,$(call FN_TOKEN,$(distDirEntry),:,1)),$(call FN_TOKEN,$(distDirEntry),:,1)/$(distFile):$(if $(call FN_TOKEN,$(distDirEntry),:,2),$(call FN_TOKEN,$(distDirEntry),:,2)/,)$(distFile)))
__builder_mk_dist_files__ := $(call FN_UNIQUE,$(foreach distFileEntry,$(__builder_mk_dist_files__),$(call __builder_mk_fn_dist_adjust_file_entry__,$(distFileEntry))))
__builder_mk_dist_files__ := $(call FN_UNIQUE,$(foreach distFileEntry,$(__builder_mk_dist_files__),$(call FN_TOKEN,$(distFileEntry),:,1):$(O_DIST_DIR)/$(call FN_TOKEN,$(distFileEntry),:,2)))

# NOTE: Windows does not have standardized support for hard links
ifeq ($(NATIVE_OS),windows)
    __builder_mk_ln_f__ := cp
else
    __builder_mk_ln_f__ ?= ln -f
endif

# Template for distribution artifacts targets
# $(call __builder_mk_dist_deps_template__,src,dest)
define __builder_mk_dist_deps_template__
__builder_mk_dist_deps__ += $(2)

$(2): $(1)
	@echo [DIST] $$@
	@mkdir -p $$(dir $$@)
	$(O_VERBOSE)$(__builder_mk_ln_f__) $$< $$@
endef

$(foreach distFileEntry,$(__builder_mk_dist_files__),$(eval $(call __builder_mk_dist_deps_template__,$(call FN_TOKEN,$(distFileEntry),:,1),$(call FN_TOKEN,$(distFileEntry),:,2))))
__builder_mk_dist_deps__ := $(call FN_UNIQUE,$(__builder_mk_dist_deps__))

undefine __builder_mk_ln_f__

ifdef PRE_DIST_DEPS
    ifneq ($(origin PRE_DIST_DEPS),file)
        $(error [PRE_DIST_DEPS] Not defined in a makefile (origin: $(origin PRE_DIST_DEPS)))
    endif
endif
ifdef POST_DIST_DEPS
    ifneq ($(origin POST_DIST_DEPS),file)
        $(error [POST_DIST_DEPS] Not defined in a makefile (origin: $(origin POST_DIST_DEPS)))
    endif
endif
.PHONY: pre-dist
pre-dist: build $(PRE_DIST_DEPS)

$(eval --__builder_mk_dist__: pre-dist $(__builder_mk_dist_deps__))

--__builder_mk_post-dist__: --__builder_mk_dist__ $(POST_DIST_DEPS)

.PHONY: dist
dist: --__builder_mk_post-dist__
# ==============================================================================

# LAZY -------------------------------------------------------------------------
ifdef LAZY
    ifneq ($(origin LAZY),file)
        $(error [LAZY] Not defined in a makefile (origin: $(origin LAZY)))
    endif
endif

$(eval $(LAZY))
# ------------------------------------------------------------------------------

undefine __builder_mk_self_dir__
undefine __builder_mk_dist_deps__
undefine __builder_mk_build_target__
undefine __builder_mk_cxx_template__
undefine __builder_mk_as_template__
undefine __builder_mk_o__
undefine __builder_mk_src_dirs__
undefine __builder_mk_skipped_src_files__
undefine __builder_mk_skipped_src_dirs__
undefine __builder_mk_std_host_includes__
undefine __builder_mk_fn_host_factorize__
undefine __builder_mk_host_factorize__
undefine __builder_mk_host_factorizer__
undefine __builder_mk_host_factorizer_factors__
undefine __builder_mk_host_factorizer_previous__
undefine __builder_mk_host_factorizer_current__
undefine __builder_mk_project_host_mk_includes__
undefine __builder_mk_project_host_token_src_dirs__
undefine __builder_mk_project_host_token__
undefine __builder_mk_libs__
undefine __builder_mk_libs_parse_entry__
undefine __builder_mk_libs_parse_entries__
undefine __builder_mk_libs_parse_entry_lib_includes__
undefine __builder_mk_libs_parse_entry_lib_dirs__
undefine __builder_mk_libs_parse_entry_ld_libs__
undefine __builder_mk_dist_dirs__
undefine __builder_mk_dist_files__
undefine __builder_mk_fn_dist_adjust_dir_entry__
undefine __builder_mk_fn_dist_adjust_file_entry__
undefine __builder_mk_dist_deps_template__
undefine __builder_mk_dist_deps__
undefine __builder_mk_dep_files__
undefine __builder_mk_obj_suffix__
undefine __builder_mk_obj_files__
undefine __builder_mk_origin_ar__
undefine __builder_mk_origin_as__
undefine __builder_mk_origin_cc__
undefine __builder_mk_origin_cxx__
undefine __builder_mk_origin_ld__
undefine __builder_mk_ld__
undefine __builder_mk_is_cpp_project__
undefine __builder_mk_include_flags__
undefine __builder_mk_include_dirs__

endif # ifndef __builder_mk__
