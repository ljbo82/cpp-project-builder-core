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

# GCC toolchain

ifndef cpb_builder_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_include_toolchain_mk
cpb_include_toolchain_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_include_toolchain_mk))libs.mk

$(call fn_check_reserved,cpb_include_toolchain_mk_is_cpp_project)
$(call fn_check_reserved,cpb_include_toolchain_mk_ld)
$(call fn_check_reserved,cpb_include_toolchain_mk_cflags)
$(call fn_check_reserved,cpb_include_toolchain_mk_cxxflags)
$(call fn_check_reserved,cpb_include_toolchain_mk_asflags)
$(call fn_check_reserved,cpb_include_toolchain_mk_ldflags)
$(call fn_check_reserved,cpb_include_toolchain_mk_include_flags)
$(call fn_check_reserved,cpb_include_toolchain_mk_obj_suffix)
$(call fn_check_reserved,cpb_include_toolchain_mk_obj_files)
$(call fn_check_reserved,cpb_include_toolchain_mk_dep_files)
$(call fn_check_reserved,cpb_include_toolchain_mk_cxx_template)
$(call fn_check_reserved,cpb_include_toolchain_mk_as_template)
$(call fn_check_reserved,cpb_include_toolchain_mk_fn_dist_adjust_dir_entry)
$(call fn_check_reserved,cpb_include_toolchain_mk_fn_dist_adjust_file_entry)
$(call fn_check_reserved,cpb_include_toolchain_mk_dist_deps_template)
$(call fn_check_reserved,cpb_include_toolchain_mk_dist_deps)

VARS += LIBS STRIP_RELEASE RELEASE_OPTIMIZATION_LEVEL CROSS_COMPILE AS ASFLAGS CC CFLAGS CXX CXXFLAGS AR ARFLAGS LD LDFLAGS LIBS_FLAGS

# Strips release build ---------------------------------------------------------
# NOTE: A host layer may have set STRIP_RELEASE
ifeq ($(DEBUG),0)
    STRIP_RELEASE ?= 1
    $(call fn_check_origin,STRIP_RELEASE,file)
    $(call fn_check_non_empty,STRIP_RELEASE)
    $(call fn_check_no_whitespace,STRIP_RELEASE)
    $(call fn_check_options,STRIP_RELEASE,0 1)
endif
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
# NOTE: A host layer may have set RELEASE_OPTIMIZATION_LEVEL
ifeq ($(DEBUG),0)
    RELEASE_OPTIMIZATION_LEVEL ?= 2
    $(call fn_check_origin,RELEASE_OPTIMIZATION_LEVEL,file)
    $(call fn_check_non_empty,RELEASE_OPTIMIZATION_LEVEL)
    $(call fn_check_no_whitespace,RELEASE_OPTIMIZATION_LEVEL)
    $(call fn_check_options,RELEASE_OPTIMIZATION_LEVEL,0 1 2 3 s fast g z)
endif
# ------------------------------------------------------------------------------

# Compiler management ----------------------------------------------------------
override ARFLAGS := $(subst v,,$(subst r,,$(ARFLAGS)))

# AS
AS ?= as
ifeq ($(origin AS),default)
    AS := as
else
    $(call fn_check_non_empty,AS)
endif

# CC
CC ?= gcc
ifeq ($(origin CC),default)
    CC := gcc
else
    $(call fn_check_non_empty,CC)
endif

# CXX
CXX ?= g++
ifeq ($(origin CXX),default)
    CXX := g++
else
    $(call fn_check_non_empty,CXX)
endif

# AR
AR ?= ar
ifeq ($(origin AR),default)
    AR := ar
else
    $(call fn_check_non_empty,AR)
endif

# LD
ifneq ($(SRC_FILES),)
    cpb_include_toolchain_mk_is_cpp_project := $(strip $(filter %.cpp %.cxx %.cc,$(SRC_FILES)))
    ifeq ($(cpb_include_toolchain_mk_is_cpp_project),)
        cpb_include_toolchain_mk_is_cpp_project := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(if $(wildcard $(includeDir)),$(call fn_shell,find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null),)))
    endif

    ifeq ($(cpb_include_toolchain_mk_is_cpp_project),)
        # Pure C project
        cpb_include_toolchain_mk_ld := gcc
    else
        # C/C++ project
        cpb_include_toolchain_mk_ld := g++
    endif
else
    cpb_include_toolchain_mk_ld := gcc
endif

LD ?= $(cpb_include_toolchain_mk_ld)
ifeq ($(origin LD),default)
    LD := $(cpb_include_toolchain_mk_ld)
else
    $(call fn_check_non_empty,LD)
endif

cpb_include_toolchain_mk_cflags += -Wall
cpb_include_toolchain_mk_cxxflags += -Wall

ifneq ($(DEBUG),0)
    cpb_include_toolchain_mk_cflags += -g3
    cpb_include_toolchain_mk_cxxflags += -g3
    cpb_include_toolchain_mk_asflags += -g3
else
    ifneq ($(RELEASE_OPTIMIZATION_LEVEL),)
        cpb_include_toolchain_mk_cflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
        cpb_include_toolchain_mk_cxxflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
    endif

    ifneq ($(STRIP_RELEASE),0)
        cpb_include_toolchain_mk_cflags += -s
        cpb_include_toolchain_mk_cxxflags += -s
        cpb_include_toolchain_mk_ldflags += -s
    endif
endif

ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),shared)
        cpb_include_toolchain_mk_cflags += -fPIC
        cpb_include_toolchain_mk_cxxflags += -fPIC
        cpb_include_toolchain_mk_ldflags += -shared
    endif
endif

cpb_include_toolchain_mk_include_flags := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

override CFLAGS   := $(strip $(call fn_unique,-MMD -MP $(cpb_include_toolchain_mk_include_flags) $(cpb_include_toolchain_mk_cflags) $(CFLAGS)))
override CXXFLAGS := $(strip $(call fn_unique,-MMD -MP $(cpb_include_toolchain_mk_include_flags) $(cpb_include_toolchain_mk_cxxflags) $(CXXFLAGS)))
override ASFLAGS  := $(strip $(call fn_unique,-MMD -MP $(cpb_include_toolchain_mk_include_flags) $(cpb_include_toolchain_mk_asflags) $(ASFLAGS)))
override ARFLAGS  := $(strip $(call fn_unique,rcs $(ARFLAGS)))
override LDFLAGS  := $(strip $(call fn_unique,$(cpb_include_toolchain_mk_ldflags) $(LDFLAGS)) $(LIBS_FLAGS))
# ------------------------------------------------------------------------------

# build ========================================================================
ifeq ($(PROJ_TYPE),lib)
    # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
    ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
        cpb_include_toolchain_mk_obj_suffix := .lo
    else
        cpb_include_toolchain_mk_obj_suffix := .o
    endif
else ifeq ($(PROJ_TYPE),app)
    cpb_include_toolchain_mk_obj_suffix := .o
endif

cpb_include_toolchain_mk_obj_files := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(cpb_include_toolchain_mk_obj_suffix))

ifeq ($(PROJ_TYPE),lib)
    # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
    ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
        cpb_include_toolchain_mk_dep_files := $(cpb_include_toolchain_mk_obj_files:.lo=.d)
    else
        cpb_include_toolchain_mk_dep_files := $(cpb_include_toolchain_mk_obj_files:.o=.d)
    endif
else ifeq ($(PROJ_TYPE),app)
    cpb_include_toolchain_mk_dep_files := $(cpb_include_toolchain_mk_obj_files:.o=.d)
endif

ifneq ($(SRC_FILES),)
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BUILD_DEPS += --cpb_include_toolchain_mk_pre_build_check $(O_BUILD_DIR)/$(ARTIFACT)

.PHONY: --cpb_include_toolchain_mk_pre_build_check
--cpb_include_toolchain_mk_pre_build_check:
    ifneq ($(HOST),$(NATIVE_HOST))
        ifeq ($(origin CROSS_COMPILE),undefined)
	        $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
        endif
    endif

$(O_BUILD_DIR)/$(ARTIFACT): $(cpb_include_toolchain_mk_obj_files)
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
	        $(call fn_log_info,$(V),[LD] $@)
	        $(V_PREFIX)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(cpb_include_toolchain_mk_obj_files) $(LDFLAGS))
        else ifeq ($(LIB_TYPE),static)
	        $(call fn_log_info,$(V),[AR] $@)
	        $(V_PREFIX)$(CROSS_COMPILE)$(AR) $(strip $(ARFLAGS) $@ $(cpb_include_toolchain_mk_obj_files))
        endif
    else ifeq ($(PROJ_TYPE),app)
	    $(call fn_log_info,$(V),[LD] $@)
	    $(V_PREFIX)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(cpb_include_toolchain_mk_obj_files) $(LDFLAGS))
    endif

# C sources --------------------------------------------------------------------
$(O_BUILD_DIR)/%.c$(cpb_include_toolchain_mk_obj_suffix): %.c
	$(call fn_log_info,$(V),[CC] $@)
	@mkdir -p $(dir $@)
	$(V_PREFIX)$(CROSS_COMPILE)$(CC) $(strip $(CFLAGS) -c $< -o $@)
# ------------------------------------------------------------------------------

# C++ sources ------------------------------------------------------------------
define cpb_include_toolchain_mk_cxx_template =
$(O_BUILD_DIR)/%.$(1)$(cpb_include_toolchain_mk_obj_suffix): %.$(1)
	$$(call fn_log_info,$$(V),[CXX] $$@)
	@mkdir -p $$(dir $$@)
	$(V_PREFIX)$(CROSS_COMPILE)$(CXX) $$(strip $(CXXFLAGS) -c $$< -o $$@)
endef

$(eval $(call cpb_include_toolchain_mk_cxx_template,cpp))
$(eval $(call cpb_include_toolchain_mk_cxx_template,cxx))
$(eval $(call cpb_include_toolchain_mk_cxx_template,cc))
# ------------------------------------------------------------------------------

# Assembly sources -------------------------------------------------------------
define cpb_include_toolchain_mk_as_template =
$(O_BUILD_DIR)/%.$(1)$(cpb_include_toolchain_mk_obj_suffix): %.$(1)
	$$(call fn_log_info,$$(V),[AS] $$@)
	@mkdir -p $$(dir $$@)
	$(V_PREFIX)$(CROSS_COMPILE)$(AS) $$(strip $(ASFLAGS) -c $$< -o $$@)
endef

$(eval $(call cpb_include_toolchain_mk_as_template,s))
$(eval $(call cpb_include_toolchain_mk_as_template,S))
# ------------------------------------------------------------------------------

-include $(cpb_include_toolchain_mk_dep_files)
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
endif
# ==============================================================================

endif # ifndef cpb_include_toolchain_mk
