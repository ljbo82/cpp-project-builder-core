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

ifndef cpb_toolchains_gcc_toolchain_mk
cpb_toolchains_gcc_toolchain_mk := $(lastword $(MAKEFILE_LIST))

ifndef cpb_builder_mk
    $(error This file cannot be manually included)
endif

override undefine cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir
override undefine cpb_toolchains_gcc_toolchain_mk_libs_template1
override undefine cpb_toolchains_gcc_toolchain_mk_libs_has_lib_dir
override undefine cpb_toolchains_gcc_toolchain_mk_libs_ldflags
override undefine cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_name
override undefine cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_dir
override undefine cpb_toolchains_gcc_toolchain_mk_libs_template
override undefine cpb_toolchains_gcc_toolchain_mk_libs_fn_template
override undefine cpb_toolchains_gcc_toolchain_mk_is_cpp_project
override undefine cpb_toolchains_gcc_toolchain_mk_ld
override undefine cpb_toolchains_gcc_toolchain_mk_cflags
override undefine cpb_toolchains_gcc_toolchain_mk_cxxflags
override undefine cpb_toolchains_gcc_toolchain_mk_asflags
override undefine cpb_toolchains_gcc_toolchain_mk_ldflags
override undefine cpb_toolchains_gcc_toolchain_mk_include_flags
override undefine cpb_toolchains_gcc_toolchain_mk_obj_suffix
override undefine cpb_toolchains_gcc_toolchain_mk_obj_files
override undefine cpb_toolchains_gcc_toolchain_mk_dep_files
override undefine cpb_toolchains_gcc_toolchain_mk_cxx_template
override undefine cpb_toolchains_gcc_toolchain_mk_as_template
override undefine cpb_toolchains_gcc_toolchain_mk_fn_dist_adjust_dir_entry
override undefine cpb_toolchains_gcc_toolchain_mk_fn_dist_adjust_file_entry
override undefine cpb_toolchains_gcc_toolchain_mk_dist_deps_template
override undefine cpb_toolchains_gcc_toolchain_mk_dist_deps

ifdef CPB_DEPS
    $(error [CPB_DEPS] Reserved variable)
endif

DEFAULT_VAR_SET += CPB_DEPS LIBS STRIP_RELEASE OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL CROSS_COMPILE AS ASFLAGS CC CFLAGS CXX CXXFLAGS AR ARFLAGS LD LDFLAGS

# Strips release build ---------------------------------------------------------
# NOTE: A host layer may have set STRIP_RELEASE
STRIP_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,STRIP_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,STRIP_RELEASE)
$(call FN_CHECK_NO_WHITESPACE,STRIP_RELEASE)
$(call FN_CHECK_WORDS,STRIP_RELEASE,0 1)
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
# NOTE: A host layer may have set OPTIMIZE_RELEASE and RELEASE_OPTIMIZATION_LEVEL
OPTIMIZE_RELEASE ?= 1
$(call FN_CHECK_ORIGIN,OPTIMIZE_RELEASE,file)
$(call FN_CHECK_NON_EMPTY,OPTIMIZE_RELEASE)
$(call FN_CHECK_NO_WHITESPACE,OPTIMIZE_RELEASE)
$(call FN_CHECK_WORDS,OPTIMIZE_RELEASE,0 1)
ifneq ($(OPTIMIZE_RELEASE),0)
    RELEASE_OPTIMIZATION_LEVEL ?= 2
endif
# ------------------------------------------------------------------------------

# deps =========================================================================
.PHONY: deps
deps:
	@printf -- "$(strip $(CPB_DEPS))"
# ==============================================================================

# Libs -------------------------------------------------------------------------
ifdef LIBS
    $(call FN_CHECK_ORIGIN,LIBS,file)
endif

export cpb_toolchains_gcc_toolchain_mk_o_libs_dir ?= $(abspath $(O)/libs)
cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir =$(call FN_REL_DIR,$(CURDIR),$(cpb_toolchains_gcc_toolchain_mk_o_libs_dir))

#### TODO: INSTEAD OF lib_name[:lib_dir[:host]] use lib_name[:lib_dir[:target]]
####       By declaring a target application can define its way to build the library

#$(call cpb_toolchains_gcc_toolchain_mk_libs_template1,<lib_name>,[lib_dir],[host])
define cpb_toolchains_gcc_toolchain_mk_libs_template1
cpb_toolchains_gcc_toolchain_mk_libs_has_lib_dir := $$(if $$(or $$(cpb_toolchains_gcc_toolchain_mk_libs_has_lib_dir),$(2)),1,)
cpb_toolchains_gcc_toolchain_mk_libs_ldflags += $(strip -l$(1) $(if $(2),`$(MAKE) --no-print-directory -C $(call FN_REL_DIR,$(CURDIR),$(2)) deps$(if $(3), HOST=$(3),);`,))

$(if $(2),PRE_BUILD_DEPS += $$(cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir)/.$(1),)
$(if $(2),--cpb-$(1):,)
$(if $(2),	$$(VERBOSE)$$(MAKE) -C $(call FN_REL_DIR,$(CURDIR),$(2)) O=$$(call FN_REL_DIR,$(2),$$(cpb_toolchains_gcc_toolchain_mk_o_libs_dir)) BUILD_SUBDIR=$(1) DIST_MARKER=.$(1)$(if $(3), HOST=$(3),),)
$(if $(2),$$(cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir)/.$(1): --cpb-$(1) ;,)

endef

# $(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_name,<lib_entry>)
cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_name = $(word 1,$(subst :, ,$(1)))

# $(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_dir,<lib_entry>)
cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_dir = $(word 2,$(subst :, ,$(1)))

# $(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_host,<lib_entry>)
cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_host = $(word 3,$(subst :, ,$(1)))

# $(call cpb_toolchains_gcc_toolchain_mk_libs_template,<lib_entry>)
cpb_toolchains_gcc_toolchain_mk_libs_template = $(call cpb_toolchains_gcc_toolchain_mk_libs_template1,$(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_name,$(1)),$(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_dir,$(1)),$(call cpb_toolchains_gcc_toolchain_mk_libs_fn_lib_host,$(1)))

# $(call cpb_toolchains_gcc_toolchain_mk_libs_fn_template,<lib_entry>)
cpb_toolchains_gcc_toolchain_mk_libs_fn_template = $(eval $(call cpb_toolchains_gcc_toolchain_mk_libs_template,$(1)))

$(foreach lib,$(LIBS),$(call cpb_toolchains_gcc_toolchain_mk_libs_fn_template,$(lib)))

CPB_DEPS := $(cpb_toolchains_gcc_toolchain_mk_libs_ldflags)
ifeq ($(cpb_toolchains_gcc_toolchain_mk_libs_has_lib_dir),1)
    INCLUDE_DIRS += $(cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir)/dist/include
    LDFLAGS := $(LDFLAGS) -L$(cpb_toolchains_gcc_toolchain_mk_o_libs_rel_dir)/dist/lib $(CPB_DEPS)
else
    LDFLAGS := $(LDFLAGS) $(CPB_DEPS)
endif
LDFLAGS := $(strip $(LDFLAGS))
# ------------------------------------------------------------------------------

ifneq ($(MAKECMDGOALS),deps) # *************************************************

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
ARFLAGS := $(subst v,,$(subst r,,$(ARFLAGS)))

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
    ifeq ($(cpb_toolchains_gcc_toolchain_mk_is_cpp_project),)
        cpb_toolchains_gcc_toolchain_mk_is_cpp_project := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null)))
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

CFLAGS   := $(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_cflags) $(CFLAGS))
CXXFLAGS := $(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_cxxflags) $(CXXFLAGS))
ASFLAGS  := $(strip -MMD -MP $(cpb_toolchains_gcc_toolchain_mk_include_flags) $(cpb_toolchains_gcc_toolchain_mk_asflags) $(ASFLAGS))
ARFLAGS  := $(strip rcs $(ARFLAGS))
LDFLAGS  := $(strip $(cpb_toolchains_gcc_toolchain_mk_ldflags) $(LDFLAGS))
# ------------------------------------------------------------------------------

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

.PHONY: --cpb_toolchains_gcc_toolchain_mk_pre_build_check
--cpb_toolchains_gcc_toolchain_mk_pre_build_check:
    ifneq ($(HOST),$(NATIVE_HOST))
        ifeq ($(origin CROSS_COMPILE),undefined)
	        $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
        endif
    endif

ifneq ($(SRC_FILES),)
    $(O_BUILD_DIR)/$(ARTIFACT): $(PRE_BUILD_DEPS) $(cpb_toolchains_gcc_toolchain_mk_obj_files) $(BUILD_DEPS)
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

    .PHONY: build
    build: --cpb_toolchains_gcc_toolchain_mk_pre_build_check $(O_BUILD_DIR)/$(ARTIFACT) $(POST_BUILD_DEPS) ;
else
    .PHONY: build
    build: $(PRE_BUILD_DEPS) $(BUILD_DEPS) $(POST_BUILD_DEPS) ;
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
# ==============================================================================

endif # ifneq ($(MAKECMDGOALS),deps) *******************************************

endif # ifndef cpb_toolchains_gcc_toolchain_mk
