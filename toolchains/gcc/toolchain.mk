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

ifndef cpb_toolchains_gcc_toolchain_mk
cpb_toolchains_gcc_toolchain_mk := $(lastword $(MAKEFILE_LIST))

include $(dir $(cpb_toolchains_gcc_toolchain_mk))deps.mk

$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_is_cpp_project)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_ld)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_cflags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_cxxflags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_asflags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_ldflags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_include_flags)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_obj_suffix)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_obj_files)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_dep_files)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_cxx_template)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_as_template)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_fn_dist_adjust_dir_entry)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_fn_dist_adjust_file_entry)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_dist_deps_template)
$(call FN_CHECK_RESERVED,cpb_toolchains_gcc_toolchain_mk_dist_deps)

DEFAULT_VAR_SET += LIBS STRIP_RELEASE OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL CROSS_COMPILE AS ASFLAGS CC CFLAGS CXX CXXFLAGS AR ARFLAGS LD LDFLAGS

# Strips release build ---------------------------------------------------------
# NOTE: A host layer may have set STRIP_RELEASE
STRIP_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,STRIP_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,STRIP_RELEASE)
$(call FN_CHECK_NO_WHITESPACE,STRIP_RELEASE)
$(call FN_CHECK_OPTIONS,STRIP_RELEASE,0 1)
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
# NOTE: A host layer may have set OPTIMIZE_RELEASE and RELEASE_OPTIMIZATION_LEVEL
OPTIMIZE_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,OPTIMIZE_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,OPTIMIZE_RELEASE)
$(call FN_CHECK_NO_WHITESPACE,OPTIMIZE_RELEASE)
$(call FN_CHECK_OPTIONS,OPTIMIZE_RELEASE,0 1)
ifneq ($(OPTIMIZE_RELEASE),0)
    RELEASE_OPTIMIZATION_LEVEL ?= 2
endif
# ------------------------------------------------------------------------------

# Compiler management ----------------------------------------------------------
ifeq ($(origin CFLAGS),command line)
    $(error [CFLAGS] Variable cannot be defined via command line)
endif

ifeq ($(origin CXXFLAGS),command line)
    $(error [CXXFLAGS] Variable cannot be defined via command line)
endif

ifeq ($(origin ASFLAGS),command line)
    $(error [ASFLAGS] Variable cannot be defined via command line)
endif

ifeq ($(origin ARFLAGS),command line)
    $(error [ARFLAGS] Variable cannot be defined via command line)
endif
override ARFLAGS := $(subst v,,$(subst r,,$(ARFLAGS)))

ifeq ($(origin LDFLAGS),command line)
    $(error [LDFLAGS] Variable cannot be defined via command line)
endif

# AS
AS ?= as
ifeq ($(origin AS),default)
    AS := as
else
    $(call FN_CHECK_NON_EMPTY,AS)
endif

# CC
CC ?= gcc
ifeq ($(origin CC),default)
    CC := gcc
else
    $(call FN_CHECK_NON_EMPTY,CC)
endif

# CXX
CXX ?= g++
ifeq ($(origin CXX),default)
    CXX := g++
else
    $(call FN_CHECK_NON_EMPTY,CXX)
endif

# AR
AR ?= ar
ifeq ($(origin AR),default)
    AR := ar
else
    $(call FN_CHECK_NON_EMPTY,AR)
endif

# LD
ifneq ($(SRC_FILES),)
    cpb_toolchains_gcc_toolchain_mk_is_cpp_project := $(strip $(filter %.cpp %.cxx %.cc,$(SRC_FILES)))
    ifeq ($(SKIP_DIR_INSPECTION),0)
        ifeq ($(cpb_toolchains_gcc_toolchain_mk_is_cpp_project),)
            cpb_toolchains_gcc_toolchain_mk_is_cpp_project := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null)))
        endif
    endif

    ifeq ($(cpb_toolchains_gcc_toolchain_mk_is_cpp_project),)
        # Pure C project
        cpb_toolchains_gcc_toolchain_mk_ld := gcc
    else
        # C/C++ project
        cpb_toolchains_gcc_toolchain_mk_ld := g++
    endif
else
    cpb_toolchains_gcc_toolchain_mk_ld := gcc
endif

LD ?= $(cpb_toolchains_gcc_toolchain_mk_ld)
ifeq ($(origin LD),default)
    LD := $(cpb_toolchains_gcc_toolchain_mk_ld)
else
    $(call FN_CHECK_NON_EMPTY,LD)
endif

cpb_toolchains_gcc_toolchain_mk_cflags += -Wall
cpb_toolchains_gcc_toolchain_mk_cxxflags += -Wall

ifneq ($(DEBUG),0)
    cpb_toolchains_gcc_toolchain_mk_cflags += -g3
    cpb_toolchains_gcc_toolchain_mk_cxxflags += -g3
    cpb_toolchains_gcc_toolchain_mk_asflags += -g3
else
    ifneq ($(OPTIMIZE_RELEASE),0)
        cpb_toolchains_gcc_toolchain_mk_cflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
        cpb_toolchains_gcc_toolchain_mk_cxxflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
    endif

    ifneq ($(STRIP_RELEASE),0)
        cpb_toolchains_gcc_toolchain_mk_cflags += -s
        cpb_toolchains_gcc_toolchain_mk_cxxflags += -s
        cpb_toolchains_gcc_toolchain_mk_ldflags += -s
    endif
endif

ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),shared)
        cpb_toolchains_gcc_toolchain_mk_cflags += -fPIC
        cpb_toolchains_gcc_toolchain_mk_cxxflags += -fPIC
        cpb_toolchains_gcc_toolchain_mk_ldflags += -shared
    endif
endif

cpb_toolchains_gcc_toolchain_mk_include_flags := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

override CFLAGS   := $(call FN_UNIQUE,$(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_cflags) $(CFLAGS)))
override CXXFLAGS := $(call FN_UNIQUE,$(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_cxxflags) $(CXXFLAGS)))
override ASFLAGS  := $(call FN_UNIQUE,$(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_asflags) $(ASFLAGS)))
override ARFLAGS  := $(call FN_UNIQUE,$(strip rcs $(ARFLAGS)))
override LDFLAGS  := $(call FN_UNIQUE,$(strip $(cpb_toolchains_gcc_toolchain_mk_ldflags) $(LDFLAGS)))
# ------------------------------------------------------------------------------

# build ========================================================================
ifeq ($(PROJ_TYPE),lib)
    # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
    ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
        cpb_toolchains_gcc_toolchain_mk_obj_suffix := .lo
    else
        cpb_toolchains_gcc_toolchain_mk_obj_suffix := .o
    endif
else ifeq ($(PROJ_TYPE),app)
    cpb_toolchains_gcc_toolchain_mk_obj_suffix := .o
endif

cpb_toolchains_gcc_toolchain_mk_obj_files := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(cpb_toolchains_gcc_toolchain_mk_obj_suffix))

ifeq ($(PROJ_TYPE),lib)
    # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
    ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
        cpb_toolchains_gcc_toolchain_mk_dep_files := $(cpb_toolchains_gcc_toolchain_mk_obj_files:.lo=.d)
    else
        cpb_toolchains_gcc_toolchain_mk_dep_files := $(cpb_toolchains_gcc_toolchain_mk_obj_files:.o=.d)
    endif
else ifeq ($(PROJ_TYPE),app)
    cpb_toolchains_gcc_toolchain_mk_dep_files := $(cpb_toolchains_gcc_toolchain_mk_obj_files:.o=.d)
endif

ifneq ($(SRC_FILES),) #*********************************************************
BUILD_DEPS += --cpb_toolchains_gcc_toolchain_mk_pre_build_check $(O_BUILD_DIR)/$(ARTIFACT)

.PHONY: --cpb_toolchains_gcc_toolchain_mk_pre_build_check
--cpb_toolchains_gcc_toolchain_mk_pre_build_check:
    ifneq ($(HOST),$(NATIVE_HOST))
        ifeq ($(origin CROSS_COMPILE),undefined)
	        $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
        endif
    endif

$(O_BUILD_DIR)/$(ARTIFACT): $(cpb_toolchains_gcc_toolchain_mk_obj_files)
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
	        @echo [LD] $@
	        $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(cpb_toolchains_gcc_toolchain_mk_obj_files) $(LDFLAGS))
        else ifeq ($(LIB_TYPE),static)
	        @echo [AR] $@
	        $(VERBOSE)$(CROSS_COMPILE)$(AR) $(strip $(ARFLAGS) $@ $(cpb_toolchains_gcc_toolchain_mk_obj_files))
        endif
    else ifeq ($(PROJ_TYPE),app)
	    @echo [LD] $@
	    $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(cpb_toolchains_gcc_toolchain_mk_obj_files) $(LDFLAGS))
    endif

# C sources --------------------------------------------------------------------
$(O_BUILD_DIR)/%.c$(cpb_toolchains_gcc_toolchain_mk_obj_suffix): %.c
	@echo [CC] $@
	@mkdir -p $(dir $@)
	$(VERBOSE)$(CROSS_COMPILE)$(CC) $(strip $(CFLAGS) -c $< -o $@)
# ------------------------------------------------------------------------------

# C++ sources ------------------------------------------------------------------
define cpb_toolchains_gcc_toolchain_mk_cxx_template =
$(O_BUILD_DIR)/%.$(1)$(cpb_toolchains_gcc_toolchain_mk_obj_suffix): %.$(1)
	@echo [CXX] $$@
	@mkdir -p $$(dir $$@)
	$(VERBOSE)$(CROSS_COMPILE)$(CXX) $$(strip $(CXXFLAGS) -c $$< -o $$@)
endef

$(eval $(call cpb_toolchains_gcc_toolchain_mk_cxx_template,cpp))
$(eval $(call cpb_toolchains_gcc_toolchain_mk_cxx_template,cxx))
$(eval $(call cpb_toolchains_gcc_toolchain_mk_cxx_template,cc))
# ------------------------------------------------------------------------------

# Assembly sources -------------------------------------------------------------
define cpb_toolchains_gcc_toolchain_mk_as_template =
$(O_BUILD_DIR)/%.$(1)$(cpb_toolchains_gcc_toolchain_mk_obj_suffix): %.$(1)
	@echo [AS] $$@
	@mkdir -p $$(dir $$@)
	$(VERBOSE)$(CROSS_COMPILE)$(AS) $$(strip $(ASFLAGS) -c $$< -o $$@)
endef

$(eval $(call cpb_toolchains_gcc_toolchain_mk_as_template,s))
$(eval $(call cpb_toolchains_gcc_toolchain_mk_as_template,S))
# ------------------------------------------------------------------------------

-include $(cpb_toolchains_gcc_toolchain_mk_dep_files)
endif
# ******************************************************************************
# ==============================================================================

endif # ifndef cpb_toolchains_gcc_toolchain_mk
