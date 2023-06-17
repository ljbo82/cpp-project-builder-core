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

# Project parser

ifndef __project_mk__
__project_mk__ := 1

__project_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__project_mk_self_dir__)common.mk

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

# Loads host definitions -------------------------------------------------------

# Precedence:
# 1. Build-system-specific host definitions (from most generic to most specific,
#    for example: linux > linux/arm)
#
# 2. project-specific host definitions (from most generic to most specifc,
#    for example: linux > linux-arm > linux-arm-v9)

# Host layer factorizer auxiliary function template.
#
# This template will be called multiple times in order to prepare the list of acceptable layers.
#
# Syntax: $(call __project_mk_host_factorizer__,hostLayer)
define __project_mk_host_factorizer__
__project_mk_host_factorizer_current__  := $$(if $$(__project_mk_host_factorizer_previous__),$$(__project_mk_host_factorizer_previous__)/$(1),$(1))
__project_mk_host_factorizer_previous__ := $$(__project_mk_host_factorizer_current__)
__project_mk_host_factorizer_factors__  := $$(__project_mk_host_factorizer_factors__) $$(__project_mk_host_factorizer_current__)
endef

# Host layer factorizer auxiliary function.
#
# This function will set the accepted layers in the variable __project_mk_host_factorizer_factors__
#
# Syntax: $(call __project_mk_host_factorize__,hostString)
define __project_mk_host_factorize__
    undefine __project_mk_host_factorizer_current__
    undefine __project_mk_host_factorizer_previous__
    undefine __project_mk_host_factorizer_factors__
    $$(foreach token,$$(subst -, ,$(1)),$$(eval $$(call __project_mk_host_factorizer__,$$(token))))
endef

# Factorizer function for a host.
#
# Function will return a list of accepted layers for a given host.
#
# Syntax: $(call __project_mk_host_factorize__,hostString)
__project_mk_fn_host_factorize__ = $(eval $(call __project_mk_host_factorize__,$(1)))$(__project_mk_host_factorizer_factors__)

# Contains all valid layers for current HOST
__project_mk_host_layers__ := $(call FN_UNIQUE,$(call __project_mk_fn_host_factorize__,$(HOST)) $(HOST))

SKIP_DEFAULT_HOSTS_DIR ?= 0
ifneq ($(origin SKIP_DEFAULT_HOSTS_DIR),file)
    $(error [SKIP_DEFAULT_HOSTS_DIR] Not defined in a makefile (origin: $(origin SKIP_DEFAULT_HOSTS_DIR)))
endif
ifneq ($(SKIP_DEFAULT_HOSTS_DIR),0)
    ifneq ($(SKIP_DEFAULT_HOSTS_DIR),1)
        $(error [SKIP_DEFAULT_HOSTS_DIR] Invalid value: $(SKIP_DEFAULT_HOSTS_DIR))
    endif
endif
ifdef $(HOSTS_DIRS)
    ifneq ($(origin HOSTS_DIRS),file)
        $(error [HOSTS_DIRS] Not defined in a makefile (origin: $(origin HOSTS_DIRS)))
    endif
endif
ifeq ($(SKIP_DEFAULT_HOSTS_DIR),0)
    ifneq ($(wildcard hosts),)
        HOSTS_DIRS := $(HOSTS_DIRS) hosts
    endif
endif

HOSTS_DIRS := $(call FN_UNIQUE,$(__project_mk_self_dir__)hosts $(HOSTS_DIRS))

# Auxiliar checker for 'host.mk' and 'src' directory into a layer directory
#
# This function will add values to '__project_mk_hosts_mk_includes__' and
# '__project_mk_hosts_src_dirs__' on each call
#
# Syntax $(call __project_mk_layer_aux_parser__,hostsDir,layer)
define __project_mk_layer_aux_parser__
__project_mk_hosts_mk_includes__ += $(if $(wildcard $(1)/$(2)/host.mk),$(realpath $(1)/$(2)/host.mk),)
__project_mk_hosts_src_dirs__    += $(if $(wildcard $(1)/$(2)/src),$(1)/$(2)/src,)
endef

$(foreach hostDir,$(HOSTS_DIRS),$(eval $$(foreach layer,$$(__project_mk_host_layers__),$$(eval $$(call __project_mk_layer_aux_parser__,$(hostDir),$$(layer))))))

__project_mk_hosts_mk_includes__ := $(call FN_UNIQUE,$(strip $(__project_mk_hosts_mk_includes__)))
__project_mk_hosts_src_dirs__    := $(strip $(__project_mk_hosts_src_dirs__))

ifneq ($(__project_mk_hosts_mk_includes__),)
    include $(__project_mk_hosts_mk_includes__)
endif

# NOTE: '__project_mk_src_dirs__' will be used later
__project_mk_src_dirs__ := $(__project_mk_hosts_src_dirs__)
# ------------------------------------------------------------------------------

# LIB_TYPE ----------------------------------------------------------------------

# NOTE: host may have set a default LIB_TYPE

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
# ------------------------------------------------------------------------------

# ARTIFACT -----------------------------------------------------------------------

# NOTE: host may have set a default ARTIFACT

ARTIFACT ?= a.out
ifeq ($(ARTIFACT),)
    $(error [ARTIFACT] Missing value)
endif
ifneq ($(words $(ARTIFACT)),1)
    $(error [ARTIFACT] Value cannot have whitespaces: $(ARTIFACT))
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
        __project_mk_src_dirs__ := $(__project_mk_src_dirs__) src
    endif
endif

__project_mk_src_dirs__ := $(call FN_UNIQUE,$(__project_mk_src_dirs__) $(SRC_DIRS))
SRC_DIRS := $(__project_mk_src_dirs__)
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

__project_mk_include_dirs__ := $(__project_mk_src_dirs__)
ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
    ifneq ($(wildcard include),)
        __project_mk_include_dirs__ := $(__project_mk_include_dirs__) include
    endif
endif

__project_mk_include_dirs__ := $(__project_mk_include_dirs__) $(INCLUDE_DIRS)
INCLUDE_DIRS := $(call FN_UNIQUE,$(__project_mk_include_dirs__))
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

# Checks if any SRC_DIR is outside CURDIR
$(foreach srcDir,$(SRC_DIRS),$(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(srcDir)),,$(error [SRC_DIRS] Invalid directory: $(srcDir))))

__project_mk_src_file_filter__ := $(subst //,/,$(foreach skippedSrcDir,$(SKIPPED_SRC_DIRS),-and -not -path '$(skippedSrcDir)/*')) -and -name '*.c' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' -or -name '*.s' -or -name '*.S'

SRC_FILES := $(call FN_UNIQUE,$(filter-out $(SKIPPED_SRC_FILES),$(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f $(__project_mk_src_file_filter__) 2> /dev/null)) $(SRC_FILES)))

__project_mk_invalid_src_files__ := $(filter-out %.c %.cpp %.cxx %.cc %.s %.S,$(SRC_FILES))
ifneq ($(__project_mk_invalid_src_files__),)
    $(error [SRC_FILES] Unsupported source file(s): $(__project_mk_invalid_src_files__))
endif
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

# LIBS -------------------------------------------------------------------------
#$(call __project_mk_libs_template1__,<lib_name>,[lib_dir])
define __project_mk_libs_template1__
__project_mk_libs_has_lib_dir__ := $$(if $$(or $$(__project_mk_libs_has_lib_dir__),$(2)),1,)
__project_mk_libs_ldflags__ += -l$(1)
$(if $(2),PRE_BUILD_DEPS += $$(O)/libs/$(1).marker,)
$(if $(2),--$(1):,)
$(if $(2),	$$(O_VERBOSE)$$(MAKE) -C $(2) O=$$(call FN_REL_DIR,$(2),$$(O)/libs) BUILD_SUBDIR=$(1) DIST_MARKER=$(1).marker,)
$(if $(2),$$(O)/libs/$(1).marker: --$(1) ;,)

endef

# $(call __project_mk_libs_fn_lib_name__,<lib_entry>)
__project_mk_libs_fn_lib_name__     = $(word 1, $(subst :, ,$(1)))

# $(call __project_mk_libs_fn_lib_dir__,<lib_entry>)
__project_mk_libs_fn_lib_dir__      = $(word 2, $(subst :, ,$(1)))

# $(call __project_mk_libs_template__,<lib_entry>)
__project_mk_libs_template__    = $(call __project_mk_libs_template1__,$(call __project_mk_libs_fn_lib_name__,$(1)),$(call __project_mk_libs_fn_lib_dir__,$(1)))

# $(call __project_mk_libs_fn_template__,<lib_entry>)
__project_mk_libs_fn_template__ = $(eval $(call __project_mk_libs_template__,$(1)))

$(foreach lib,$(LIBS),$(call __project_mk_libs_fn_template__,$(lib)))
ifeq ($(__project_mk_libs_has_lib_dir__),1)
    INCLUDE_DIRS += $(O)/libs/dist/include
    LDFLAGS := $(LDFLAGS) -L$(O)/libs/dist/lib $(__project_mk_libs_ldflags__)
else
    LDFLAGS := $(LDFLAGS) $(__project_mk_libs_ldflags__)
endif
# ------------------------------------------------------------------------------

# LAZY -------------------------------------------------------------------------
ifdef LAZY
    ifneq ($(origin LAZY),file)
        $(error [LAZY] Not defined in a makefile (origin: $(origin LAZY)))
    endif
endif

$(eval $(LAZY))
# ------------------------------------------------------------------------------

undefine __project_mk_self_dir__
undefine __project_mk_host_factorizer__
undefine __project_mk_host_factorizer_current__
undefine __project_mk_host_factorizer_previous__
undefine __project_mk_host_factorizer_factors__
undefine __project_mk_host_factorize__
undefine __project_mk_fn_host_factorize__
undefine __project_mk_host_layers__
undefine __project_mk_layer_aux_parser__
undefine __project_mk_hosts_mk_includes__
undefine __project_mk_hosts_src_dirs__
undefine __project_mk_src_dirs__
undefine __project_mk_include_dirs__
undefine __project_mk_src_file_filter__
undefine __project_mk_invalid_src_files__
undefine __project_mk_libs_template1__
undefine __project_mk_libs_has_lib_dir__
undefine __project_mk_libs_ldflags__
undefine __project_mk_libs_fn_lib_name__
undefine __project_mk_libs_fn_lib_dir__
undefine __project_mk_libs_template__
undefine __project_mk_libs_fn_template__

endif # ifndef __project_mk__
