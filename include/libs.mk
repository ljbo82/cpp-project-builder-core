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

ifndef cpb_include_toolchain_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_include_libs_mk
cpb_include_libs_mk := $(lastword $(MAKEFILE_LIST))

# Unifies the output dir for all libraries -------------------------------------

# This variable has to be exported in order to sub-make calls use the same output directory
export O_LIBS_DIR ?= $(abspath $(O)/libs)
$(call fn_check_not_empty,O_LIBS_DIR)
$(call fn_check_no_whitespace,O_LIBS_DIR)
VARS += O_LIBS_DIR
# ------------------------------------------------------------------------------

# Checks for circular references -----------------------------------------------
ifeq ($(PROJ_TYPE),lib)
    ifdef cpb_include_libs_mk_lib_chain
        ifneq ($(origin cpb_include_libs_mk_lib_chain),environment)
            $(error [cpb_include_libs_mk_lib_chain] Reserved variable)
        endif
    endif

    # Allows a scenario where a lib project calls a sub-make to run a
    # test application (which in turn depends on lib project itself)
    ifneq ($(sort $(words $(cpb_include_libs_mk_lib_chain))),1)
        ifneq ($(filter $(PROJ_NAME),$(cpb_include_libs_mk_lib_chain)),)
            $(error Detected circular reference for project "$(PROJ_NAME)" ($(foreach lib,$(cpb_include_libs_mk_lib_chain),$(lib) ->) $(PROJ_NAME)))
        endif
    endif

    export cpb_include_libs_mk_lib_chain += $(PROJ_NAME)
endif
# ------------------------------------------------------------------------------

$(call fn_check_reserved,cpb_include_libs_mk_lib_template)
$(call fn_check_reserved,cpb_include_libs_mk_ldflags)
$(call fn_check_reserved,cpb_include_libs_mk_has_lib_to_build)

ifdef LIBS
    $(call fn_check_origin,LIBS,file)
endif

# $(call cpb_include_libs_mk_lib_template,libName,libSrcDir,libMakefile,libFullEntry)
define cpb_include_libs_mk_lib_template
# ******************************************************************************
$$(if $(1),,$$(error [LIBS] Missing library name in entry: $(4)))
$$(if $$(and $(2),$(LIB_MKDIR_$(1))),$$(error [LIB_MKDIR_$(1)] Value redefinition),)
$$(if $$(and $(3),$(LIB_MAKEFILE_$(1))),$$(error [LIB_MAKEFILE_$(1)] Value redefinition),)

LIB_MAKEFILE_$(1) ?= $(3)
ifneq ($$(LIB_MAKEFILE_$(1)),)
    $$(call fn_check_origin,LIB_MAKEFILE_$(1),file)
    LIB_MKFLAGS_$(1) := -f $$(LIB_MAKEFILE_$(1)) $$(LIB_MKFLAGS_$(1))
endif

LIB_MKDIR_$(1) ?= $(2)
ifneq ($$(LIB_MKDIR_$(1)),)
    $$(call fn_check_origin,LIB_MKDIR_$(1),file)
    LIB_MKFLAGS_$(1) := -C $$(LIB_MKDIR_$(1)) $$(LIB_MKFLAGS_$(1))
endif

LIB_MKFLAGS_$(1) := $$(strip $$(LIB_MKFLAGS_$(1)))

ifneq ($$(filter -l$(1),$$(cpb_include_libs_mk_ldflags)),)
    $$(error [LIBS] Duplicate library definition: $(1))
endif
cpb_include_libs_mk_ldflags += -l$(1)

ifneq ($$(or $$(LIB_MKDIR_$(1)),$$(LIB_MAKEFILE_$(1))),)
# ------------------------------------------------------------------------------
cpb_include_libs_mk_has_lib_to_build := 1
cpb_include_libs_mk_ldflags += $$$$($$(MAKE) --no-print-directory $$(strip $$(LIB_MKFLAGS_$(1))) -- --cpb-show-libs)

LIB_MKFLAGS_$(1) := $$(LIB_MKFLAGS_$(1)) O=$$(call fn_rel_dir,$$(LIB_MKDIR_$(1)),$$(O_LIBS_DIR)) BUILD_SUBDIR=$(1) DIST_MARKER=.$(1)
PRE_BUILD_DEPS += $$(O_LIBS_DIR)/.$(1)

# ==============================================================================
.PHONY: --cpb-lib-$(1)
--cpb-lib-$(1):
	$$(call fn_log_cmd,$$(V),[LIB] $(4))
	$$(V_PREFIX)$$(MAKE) $$(LIB_MKFLAGS_$(1))

$$(O_LIBS_DIR)/.$(1): --cpb-lib-$(1) ;
# ==============================================================================
# ------------------------------------------------------------------------------
endif
# ******************************************************************************
endef

$(foreach lib,$(LIBS),$(eval $(call cpb_include_libs_mk_lib_template,$(call fn_token,$(lib),:,1),$(call fn_token,$(lib),:,2),$(call fn_token,$(lib),:,3),$(lib))))

$(call fn_check_reserved,LIBS_FLAGS)
LIBS_FLAGS := $(cpb_include_libs_mk_ldflags)

ifeq ($(cpb_include_libs_mk_has_lib_to_build),1)
    INCLUDE_DIRS += $(O_LIBS_DIR)/dist/include
    LIBS_FLAGS := -L$(O_LIBS_DIR)/dist/lib $(LIBS_FLAGS)
endif

# --cpb-show-libs ==============================================================
.PHONY: --cpb-show-libs
--cpb-show-libs:
	@printf -- "$(cpb_include_libs_mk_ldflags)"
# ==============================================================================

endif # ifndef cpb_include_libs_mk
