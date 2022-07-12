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

# cpp-project-builder main makefile

ifndef __builder_mk__
__builder_mk__ := 1

__SELF_DIR__ := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__SELF_DIR__)project.mk

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

# If '-fPIC' was passed explicitly (e.g. building a static library with position-independent code),
# both CFLAGS and CXXFLAGS must have it enabled (NOTE: duplicate -fPIC options will be removed
# later)
ifneq ($(or $(filter -fPIC,$(CFLAGS)),$(filter -fPIC,$(CXXFLAGS))),)
    CFLAGS   += -fPIC
    CXXFLAGS += -fPIC
endif

__builder_mk_include_flags__ := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

CFLAGS   := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_cflags__) $(CFLAGS))
CXXFLAGS := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_cxxflags__) $(CXXFLAGS))
ASFLAGS  := $(call FN_UNIQUE, -MMD -MP $(__builder_mk_include_flags__) $(__builder_mk_asflags__) $(ASFLAGS))
LDFLAGS  := $(call FN_UNIQUE, $(__builder_mk_ldflags__) $(LDFLAGS))
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
VARS ?= $(sort ARTIFACT_DEPS DEBUG HOST O V EXTRA_DIST_DIRS EXTRA_DIST_FILES INCLUDE_DIRS LIB_TYPE POST_BUILD_DEPS POST_CLEAN_DEPS POST_DIST_DEPS PRE_BUILD_DEPS PRE_CLEAN_DEPS PRE_DIST_DEPS PROJ_NAME PROJ_TYPE PROJ_VERSION SRC_DIRS SRC_FILES AR AS ASFLAGS CC CFLAGS CROSS_COMPILE CXX CXXFLAGS LD LDFLAGS O_BUILD_DIR O_DIST_DIR HOSTS_DIRS OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL SKIP_DEFAULT_INCLUDE_DIR SKIP_DEFAULT_SRC_DIR SKIPPED_SRC_DIRS SKIPPED_SRC_FILES STRIP_RELEASE ARTIFACT)
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

--__builder_mk_pre_clean__: $(PRE_CLEAN_DEPS)

--__builder_mk_clean__: --__builder_mk_pre_clean__
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
ifdef ARTIFACT_DEPS
    ifneq ($(origin ARTIFACT_DEPS),file)
        $(error [ARTIFACT_DEPS] Not defined in a makefile (origin: $(origin ARTIFACT_DEPS)))
    endif
endif

ifneq ($(SRC_FILES),)
    ifeq ($(PROJ_TYPE),lib)
        # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
        ifneq ($(filter -fPIC,$(CFLAGS)),)
            __builder_mk_obj_suffix__ := .lo
        else
            __builder_mk_obj_suffix__ := .o
        endif
    else
        __builder_mk_obj_suffix__ := .o
    endif

    __builder_mk_obj_files__ := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(__builder_mk_obj_suffix__))

    ifeq ($(PROJ_TYPE),lib)
        # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
        ifneq ($(filter -fPIC,$(CFLAGS)),)
            __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.lo=.d)
        else
            __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.o=.d)
        endif
    else
        __builder_mk_dep_files__ := $(__builder_mk_obj_files__:.o=.d)
    endif
endif

--__builder_mk_pre_build__: $(PRE_BUILD_DEPS)
    ifneq ($(SRC_FILES),)
        ifneq ($(HOST),$(NATIVE_HOST))
            ifeq ($(origin CROSS_COMPILE),undefined)
	            $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
            endif
        endif
    endif

--__builder_mk_build__: --__builder_mk_pre_build__ $(if $(SRC_FILES),$(O_BUILD_DIR)/$(ARTIFACT),)

--__builder_mk_post_build__: --__builder_mk_build__ $(POST_BUILD_DEPS)

define __builder_mk_build_target__
.PHONY: build
build: --__builder_mk_post_build__
ifneq ($(SRC_FILES),)
    $(O_BUILD_DIR)/$(ARTIFACT): $(ARTIFACT_DEPS) $(__builder_mk_obj_files__)
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
        __builder_mk_dist_files__ := $(O_BUILD_DIR)/$(ARTIFACT):bin/$(ARTIFACT)
    else ifeq ($(PROJ_TYPE),lib)
        __builder_mk_dist_files__ := $(O_BUILD_DIR)/$(ARTIFACT):lib/$(ARTIFACT)
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

# Template for distribution artifacts targets
# $(call __builder_mk_dist_deps_template__,src,dest)
define __builder_mk_dist_deps_template__
__builder_mk_dist_deps__ += $(2)

$(2): $(1)
	@echo [DIST] $$@
	@mkdir -p $$(dir $$@)
	$(O_VERBOSE)\cp $$< $$@
endef

$(foreach distFileEntry,$(__builder_mk_dist_files__),$(eval $(call __builder_mk_dist_deps_template__,$(call FN_TOKEN,$(distFileEntry),:,1),$(call FN_TOKEN,$(distFileEntry),:,2))))
__builder_mk_dist_deps__ := $(call FN_UNIQUE,$(__builder_mk_dist_deps__))

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

--__builder_mk_pre_dist__: build $(PRE_DIST_DEPS)

define __builder_mk_dist_marker__
$(O_BUILD_DIR)/dist.marker: $(__builder_mk_dist_deps__)
	@mkdir -p $$(dir $$@)
	@touch $$@
endef

$(eval $(__builder_mk_dist_marker__))

--__builder_mk_dist__: --__builder_mk_pre_dist__ $(O_BUILD_DIR)/dist.marker

--__builder_mk_post_dist__: --__builder_mk_dist__ $(POST_DIST_DEPS)

.PHONY: dist
dist: --__builder_mk_post_dist__
# ==============================================================================

undefine __builder_mk_origin_as__
undefine __builder_mk_origin_ar__
undefine __builder_mk_origin_cc__
undefine __builder_mk_origin_cxx__
undefine __builder_mk_is_cpp_project__
undefine __builder_mk_ld__
undefine __builder_mk_origin_ld__
undefine __builder_mk_cflags__
undefine __builder_mk_cxxflags__
undefine __builder_mk_asflags__
undefine __builder_mk_ldflags__
undefine __builder_mk_include_flags__
undefine __builder_mk_obj_suffix__
undefine __builder_mk_obj_files__
undefine __builder_mk_dep_files__
undefine __builder_mk_build_target__
undefine __builder_mk_cxx_template__
undefine __builder_mk_as_template__
undefine __builder_mk_dist_dirs__
undefine __builder_mk_dist_files__
undefine __builder_mk_fn_dist_adjust_dir_entry__
undefine __builder_mk_fn_dist_adjust_file_entry__
undefine __builder_mk_dist_deps_template__
undefine __builder_mk_dist_deps__
undefine __builder_mk_dist_marker__

endif # ifndef __builder_mk__
