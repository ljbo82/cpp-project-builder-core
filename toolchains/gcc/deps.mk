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

# Library dependency management

ifndef cpb_toolchains_gcc_toolchain_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_toolchains_gcc_deps_mk
cpb_toolchains_gcc_deps_mk := $(lastword $(MAKEFILE_LIST))

# ------------------------------------------------------------------------------
ifdef cpb_toolchains_gcc_deps_mk_o_abs_libs_dir
    ifneq ($(origin cpb_toolchains_gcc_deps_mk_o_abs_libs_dir),environment)
        $(error [cpb_toolchains_gcc_deps_mk_o_abs_libs_dir] Reserved variable)
    endif
endif
# This variable has to be exported in order to sub-make calls use the same output directory
export cpb_toolchains_gcc_deps_mk_o_abs_libs_dir ?= $(abspath $(O)/libs)
# ------------------------------------------------------------------------------

$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_deps_mk_o_libs_dir)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_deps_mk_lib_template)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_deps_mk_ldflags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_deps_mk_has_lib_to_build)

ifdef LIBS
    $(call FN_CHECK_ORIGIN,LIBS,file)
endif

cpb_toolchains_gcc_deps_mk_o_libs_dir := $(call FN_REL_DIR,$(CURDIR),$(cpb_toolchains_gcc_deps_mk_o_abs_libs_dir))

# $(call cpb_toolchains_gcc_deps_mk_lib_template,libName,libSrcDir,libMakefile,libFullEntry)
define cpb_toolchains_gcc_deps_mk_lib_template
# ******************************************************************************
$$(if $(1),,$$(error [LIBS] Invalid entry: $(4)))
$$(if $$(and $(2),$(LIB_MKDIR_$(1))),$$(error [LIB_MKDIR_$(1)] Value redefinition),)
$$(if $$(and $(3),$(LIB_MAKEFILE_$(1))),$$(error [LIB_MAKEFILE_$(1)] Value redefinition),)

LIB_MAKEFILE_$(1) ?= $(3)
$$(call FN_CHECK_ORIGIN,LIB_MAKEFILE_$(1),file)

ifneq ($$(LIB_MAKEFILE_$(1)),)
    LIB_MKFLAGS_$(1) := -e $$(LIB_MAKEFILE_$(1)) $$(LIB_MKFLAGS_$(1))
endif

LIB_MKDIR_$(1) ?= $(2)
$$(call FN_CHECK_ORIGIN,LIB_MKDIR_$(1),file)

ifneq ($$(LIB_MKDIR_$(1)),)
    LIB_MKFLAGS_$(1) := -C $$(LIB_MKDIR_$(1)) $$(LIB_MKFLAGS_$(1))
endif

ifneq ($$(filter -l$(1),$$(cpb_toolchains_gcc_deps_mk_ldflags)),)
    $$(error [LIBS] Duplicate library definition: $(1))
endif
cpb_toolchains_gcc_deps_mk_ldflags += -l$(1)

ifneq ($$(or $$(LIB_MKDIR_$(1)),$$(LIB_MAKEFILE_$(1))),)
# ------------------------------------------------------------------------------
cpb_toolchains_gcc_deps_mk_has_lib_to_build := 1
cpb_toolchains_gcc_deps_mk_ldflags := $$(cpb_toolchains_gcc_deps_mk_ldflags) $$$$($$(MAKE) --no-print-directory $$(strip $$(LIB_MKFLAGS_$(1)) SKIP_DIR_INSPECTION=1) -- --show-deps)

LIB_MKFLAGS_$(1) := $$(LIB_MKFLAGS_$(1)) O=$$(call FN_REL_DIR,$$(LIB_MKDIR_$(1)),$$(cpb_toolchains_gcc_deps_mk_o_abs_libs_dir)) BUILD_SUBDIR=$(1) DIST_MARKER=.$(1)
PRE_BUILD_DEPS += $$(cpb_toolchains_gcc_deps_mk_o_libs_dir)/.$(1)

# ==============================================================================
.PHONY: --cpb-lib-$(1)
--cpb-lib-$(1):
	$$(VERBOSE)$$(MAKE) $$(LIB_MKFLAGS_$(1))

$$(cpb_toolchains_gcc_deps_mk_o_libs_dir)/.$(1): --cpb-lib-$(1) ;
# ==============================================================================
# ------------------------------------------------------------------------------
endif
# ******************************************************************************
endef

$(foreach lib,$(LIBS),$(eval $(call cpb_toolchains_gcc_deps_mk_lib_template,$(call FN_TOKEN,$(lib),:,1),$(call FN_TOKEN,$(lib),:,2),$(call FN_TOKEN,$(lib),:,3),$(lib))))

ifeq ($(cpb_toolchains_gcc_deps_mk_has_lib_to_build),1)
    INCLUDE_DIRS += $(cpb_toolchains_gcc_deps_mk_o_libs_dir)/dist/include
    override LDFLAGS := $(LDFLAGS) -L$(cpb_toolchains_gcc_deps_mk_o_libs_dir)/dist/lib $(cpb_toolchains_gcc_deps_mk_ldflags)
else
    override LDFLAGS := $(LDFLAGS) $(cpb_toolchains_gcc_deps_mk_ldflags)
endif
override LDFLAGS := $(strip $(LDFLAGS))

# --show-deps ==================================================================
.PHONY: --show-deps
--show-deps:
	@printf -- "$(cpb_toolchains_gcc_deps_mk_ldflags)"
# ==============================================================================

endif # ifndef cpb_toolchains_gcc_deps_mk
