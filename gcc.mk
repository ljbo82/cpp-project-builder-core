# Copyright (c) 2023 Leandro José Britto de Oliveira
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

# GCC management

ifndef __gcc_mk__
__gcc_mk__ := 1

ifndef __project_mk__
    $(error This file cannot be manually included)
endif

ifneq ($(filter app lib,$(PROJ_TYPE)),)
    # Libs ---------------------------------------------------------------------
    ifdef LIBS
        ifneq ($(origin LIBS),file)
            $(error [LIBS] Not defined in a makefile (origin: $(origin LIBS)))
        endif
    endif

    #$(call __gcc_mk_libs_template1__,<lib_name>,[lib_dir])
    define __gcc_mk_libs_template1__
    __gcc_mk_libs_has_lib_dir__ := $$(if $$(or $$(__gcc_mk_libs_has_lib_dir__),$(2)),1,)
    __gcc_mk_libs_ldflags__ += -l$(1)
    $(if $(2),PRE_BUILD_DEPS += $$(O)/libs/$(1).marker,)
    $(if $(2),--$(1):,)
    $(if $(2),	$$(VERBOSE)$$(MAKE) -C $(2) O=$$(call FN_REL_DIR,$(2),$$(O)/libs) BUILD_SUBDIR=$(1) DIST_MARKER=$(1).marker,)
    $(if $(2),$$(O)/libs/$(1).marker: --$(1) ;,)

    endef

    # $(call __gcc_mk_libs_fn_lib_name__,<lib_entry>)
    __gcc_mk_libs_fn_lib_name__ = $(word 1, $(subst :, ,$(1)))

    # $(call __gcc_mk_libs_fn_lib_dir__,<lib_entry>)
    __gcc_mk_libs_fn_lib_dir__ = $(word 2, $(subst :, ,$(1)))

    # $(call __gcc_mk_libs_template__,<lib_entry>)
    __gcc_mk_libs_template__ = $(call __gcc_mk_libs_template1__,$(call __gcc_mk_libs_fn_lib_name__,$(1)),$(call __gcc_mk_libs_fn_lib_dir__,$(1)))

    # $(call __gcc_mk_libs_fn_template__,<lib_entry>)
    __gcc_mk_libs_fn_template__ = $(eval $(call __gcc_mk_libs_template__,$(1)))

    $(foreach lib,$(LIBS),$(call __gcc_mk_libs_fn_template__,$(lib)))
    ifeq ($(__gcc_mk_libs_has_lib_dir__),1)
        INCLUDE_DIRS += $(O)/libs/dist/include
        LDFLAGS := $(LDFLAGS) -L$(O)/libs/dist/lib $(__gcc_mk_libs_ldflags__)
    else
        LDFLAGS := $(LDFLAGS) $(__gcc_mk_libs_ldflags__)
    endif
    # --------------------------------------------------------------------------

    # Compiler management ------------------------------------------------------
    # AS
    ifndef AS
        AS := as
    else
        __gcc_mk_origin_as__ := $(origin AS)
        ifeq ($(__gcc_mk_origin_as__),default)
            AS := as
        else ifeq ($(AS),)
            $(error [AS] Missing value)
        endif
    endif

    # CC
    ifndef CC
        CC := gcc
    else
        __gcc_mk_origin_cc__ := $(origin CC)
        ifeq ($(__gcc_mk_origin_cc__),default)
            CC := gcc
        else ifeq ($(CC),)
            $(error [CC] Missing value)
        endif
    endif

    # CXX
    ifndef CXX
        CXX := g++
    else
        __gcc_mk_origin_cxx__ := $(origin CXX)
        ifeq ($(__gcc_mk_origin_cxx__),default)
            CXX := g++
        else ifeq ($(CXX),)
            $(error [CXX] Missing value)
        endif
    endif

    # AR
    ifndef AR
        AR := ar
    else
        __gcc_mk_origin_ar__ := $(origin AR)
        ifeq ($(__gcc_mk_origin_ar__),default)
            AR := ar
        else ifeq ($(AR),)
            $(error [AR] Missing value)
        endif
    endif

    # LD
    __gcc_mk_is_cpp_project__ := $(strip $(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f -name '*.cpp' -or -name '*.cxx' -or -name '*.cc' 2> /dev/null)))
    ifeq ($(__gcc_mk_is_cpp_project__),)
        __gcc_mk_is_cpp_project__ := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null)))
    endif

    ifeq ($(__gcc_mk_is_cpp_project__),)
        # Pure C project
        __gcc_mk_ld__ := gcc
    else
        # C/C++ project
        __gcc_mk_ld__ := g++
    endif

    ifndef LD
        LD := $(__gcc_mk_ld__)
    else
        __gcc_mk_origin_ld__ := $(origin LD)
        ifeq ($(__gcc_mk_origin_ld__),default)
            LD := $(__gcc_mk_ld__)
        else ifeq ($(LD),)
            $(error [LD] Missing value)
        endif
    endif

    __gcc_mk_cflags__ += -Wall
    __gcc_mk_cxxflags__ += -Wall

    ifneq ($(DEBUG),0)
        __gcc_mk_cflags__ += -g3
        __gcc_mk_cxxflags__ += -g3
        __gcc_mk_asflags__ += -g3
    else
        ifneq ($(OPTIMIZE_RELEASE),0)
            __gcc_mk_cflags__ += -O$(RELEASE_OPTIMIZATION_LEVEL)
            __gcc_mk_cxxflags__ += -O$(RELEASE_OPTIMIZATION_LEVEL)
        endif

        ifneq ($(STRIP_RELEASE),0)
            __gcc_mk_cflags__ += -s
            __gcc_mk_cxxflags__ += -s
            __gcc_mk_ldflags__ += -s
        endif
    endif

    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
            __gcc_mk_cflags__ += -fPIC
            __gcc_mk_cxxflags__ += -fPIC
            __gcc_mk_ldflags__ += -shared
        endif
    endif

    ifdef CFLAGS
        ifeq ($(origin CFLAGS),command line)
            $(error [CFLAGS] Defined in command line. Consider using EXTRA_CFLAGS)
        endif
    endif

    ifdef CXXFLAGS
        ifeq ($(origin CXXFLAGS),command line)
            $(error [CXXFLAGS] Defined in command line. Consider using EXTRA_CXXFLAGS)
        endif
    endif

    ifdef ASFLAGS
        ifeq ($(origin ASFLAGS),command line)
            $(error [ASFLAGS] Defined in command line. Consider using EXTRA_ASFLAGS)
        endif
    endif

    ifdef ARFLAGS
        ifeq ($(origin ARFLAGS),command line)
            $(error [ARFLAGS] Defined in command line. Consider using EXTRA_ARFLAGS)
        endif
    endif

    ifdef LDFLAGS
        ifeq ($(origin LDFLAGS),command line)
            $(error [LDFLAGS] Defined in command line. Consider using EXTRA_LDFLAGS)
        endif
    endif

    __gcc_mk_include_flags__ := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

    CFLAGS   := $(call FN_UNIQUE, -MMD -MP $(__gcc_mk_include_flags__) $(__gcc_mk_cflags__) $(CFLAGS) $(EXTRA_CFLAGS))
    CXXFLAGS := $(call FN_UNIQUE, -MMD -MP $(__gcc_mk_include_flags__) $(__gcc_mk_cxxflags__) $(CXXFLAGS) $(EXTRA_CXXFLAGS))
    ASFLAGS  := $(call FN_UNIQUE, -MMD -MP $(__gcc_mk_include_flags__) $(__gcc_mk_asflags__) $(ASFLAGS) $(EXTRA_ASFLAGS))
    ARFLAGS  := $(call FN_UNIQUE, rcs $(ARFLAGS) $(EXTRA_ARFLAGS))
    LDFLAGS  := $(call FN_UNIQUE, $(__gcc_mk_ldflags__) $(LDFLAGS) $(EXTRA_LDFLAGS))
    # --------------------------------------------------------------------------
endif

.NOTPARALLEL:

# all (default) ================================================================
.DEFAULT_GOAL := all

.PHONY: all
all: dist ;
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

.PHONY: --__gcc_mk_pre_clean__
--__gcc_mk_pre_clean__: $(PRE_CLEAN_DEPS) ;

.PHONY: --__gcc_mk_clean__
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    --__gcc_mk_clean__: --__gcc_mk_pre_clean__
	    $(VERBOSE)rm -rf $(O)
else ifeq ($(PROJ_TYPE),custom)
    ifneq ($(CUSTOM_CLEAN_CMD),)
        ifneq ($(origin CUSTOM_CLEAN_CMD),file)
            $(error [CUSTOM_CLEAN_CMD] Not defined in a makefile (origin: $(origin CUSTOM_CLEAN_CMD)))
        endif
        --__gcc_mk_clean__: --__gcc_mk_pre_clean__
	        $(VERBOSE)$(CUSTOM_CLEAN_CMD)
    else
        --__gcc_mk_clean__: --__gcc_mk_pre_clean__ ;
    endif
endif

.PHONY: --__gcc_mk_post_clean__
--__gcc_mk_post_clean__: --__gcc_mk_clean__ $(POST_CLEAN_DEPS) ;

.PHONY: clean
clean: --__gcc_mk_post_clean__ ;
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

ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifeq ($(SRC_FILES),)
        $(error No source files)
    endif

    ifeq ($(PROJ_TYPE),lib)
        # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
        ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
            __gcc_mk_obj_suffix__ := .lo
        else
            __gcc_mk_obj_suffix__ := .o
        endif
    else ifeq ($(PROJ_TYPE),app)
        __gcc_mk_obj_suffix__ := .o
    endif

    __gcc_mk_obj_files__ := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(__gcc_mk_obj_suffix__))

    ifeq ($(PROJ_TYPE),lib)
        # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
        ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
            __gcc_mk_dep_files__ := $(__gcc_mk_obj_files__:.lo=.d)
        else
            __gcc_mk_dep_files__ := $(__gcc_mk_obj_files__:.o=.d)
        endif
    else ifeq ($(PROJ_TYPE),app)
        __gcc_mk_dep_files__ := $(__gcc_mk_obj_files__:.o=.d)
    endif

    .PHONY: --__gcc_mk_pre_build_check__
    --__gcc_mk_pre_build_check__:
        ifneq ($(HOST),$(NATIVE_HOST))
            ifeq ($(origin CROSS_COMPILE),undefined)
	            $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
            endif
        endif

    define __gcc_mk_artifact_target__
    $(O_BUILD_DIR)/$(ARTIFACT): $(PRE_BUILD_DEPS) $(__gcc_mk_obj_files__)
        ifeq ($(PROJ_TYPE),lib)
            ifeq ($(LIB_TYPE),shared)
	            @echo [LD] $$@
	            $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $$@ $(__gcc_mk_obj_files__) $(LDFLAGS))
            else ifeq ($(LIB_TYPE),static)
	            @echo [AR] $$@
	            $(VERBOSE)$(CROSS_COMPILE)$(AR) $(strip $(ARFLAGS) $$@ $(__gcc_mk_obj_files__))
            endif
        else ifeq ($(PROJ_TYPE),app)
	        @echo [LD] $$@
	        $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $$@ $(__gcc_mk_obj_files__) $(LDFLAGS))
        endif
    endef
    $(eval $(__gcc_mk_artifact_target__))
    undefine __gcc_mk_artifact_target__

    .PHONY: build
    build: --__gcc_mk_pre_build_check__ $(O_BUILD_DIR)/$(ARTIFACT) $(POST_BUILD_DEPS) ;

    # C sources ----------------------------------------------------------------
    $(O_BUILD_DIR)/%.c$(__gcc_mk_obj_suffix__): %.c
	    @echo [CC] $@
	    @mkdir -p $(dir $@)
	    $(VERBOSE)$(CROSS_COMPILE)$(CC) $(strip $(CFLAGS) -c $< -o $@)
    # --------------------------------------------------------------------------

    # C++ sources --------------------------------------------------------------
    define __gcc_mk_cxx_template__ =
    $(O_BUILD_DIR)/%.$(1)$(__gcc_mk_obj_suffix__): %.$(1)
	    @echo [CXX] $$@
	    @mkdir -p $$(dir $$@)
	    $(VERBOSE)$(CROSS_COMPILE)$(CXX) $$(strip $(CXXFLAGS) -c $$< -o $$@)
    endef

    $(eval $(call __gcc_mk_cxx_template__,cpp))
    $(eval $(call __gcc_mk_cxx_template__,cxx))
    $(eval $(call __gcc_mk_cxx_template__,cc))
    # --------------------------------------------------------------------------

    # Assembly sources ---------------------------------------------------------
    define __gcc_mk_as_template__ =
    $(O_BUILD_DIR)/%.$(1)$(__gcc_mk_obj_suffix__): %.$(1)
	    @echo [AS] $$@
	    @mkdir -p $$(dir $$@)
	    $(VERBOSE)$(CROSS_COMPILE)$(AS) $$(strip $(ASFLAGS) -c $$< -o $$@)
    endef

    $(eval $(call __gcc_mk_as_template__,s))
    $(eval $(call __gcc_mk_as_template__,S))
    # --------------------------------------------------------------------------

    -include $(__gcc_mk_dep_files__)
else ifeq ($(PROJ_TYPE), custom)
    .PHONY: --__gcc_mk_pre_build__
    --__gcc_mk_pre_build__: $(PRE_BUILD_DEPS) ;

    .PHONY: --__gcc_mk_build__
    ifeq ($(CUSTOM_BUILD_CMD),)
        --__gcc_mk_build__: --__gcc_mk_pre_build__ ;
    else
        --__gcc_mk_build__: --__gcc_mk_pre_build__
	        $(VERBOSE)$(CUSTOM_BUILD_CMD)
    endif

    .PHONY: --__gcc_mk_post_build__
    --__gcc_mk_post_build__: --__gcc_mk_build__ $(POST_BUILD_DEPS) ;

    .PHONY: build
    build: --__gcc_mk_post_build__ ;
endif
# ==============================================================================

# dist =========================================================================
ifneq ($(DIST_MARKER),)
    ifneq ($(words $(DIST_MARKER)),1)
        $(error [DIST_MARKER] Value cannot have whitespaces: $(DIST_MARKER))
    endif
    $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(DIST_MARKER)),,$(error [DIST_MARKER] Invalid path: $(DIST_MARKER)))
endif
ifdef DIST_DIRS
    ifneq ($(origin DIST_DIRS),file)
        $(error [DIST_DIRS] Not defined in a makefile (origin: $(origin DIST_DIRS)))
    endif
endif
ifeq ($(PROJ_TYPE),lib)
    ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
        ifneq ($(wildcard include),)
            __gcc_mk_dist_dirs__ := include:include
        endif
    endif
endif

__gcc_mk_dist_dirs__ := $(call FN_UNIQUE,$(__gcc_mk_dist_dirs__) $(DIST_DIRS))

ifdef DIST_FILES
    ifneq ($(origin DIST_FILES),file)
        $(error [DIST_FILES] Not defined in a makefile (origin: $(origin DIST_FILES)))
    endif
endif
ifeq ($(PROJ_TYPE),app)
    __gcc_mk_dist_files__ := $(O_BUILD_DIR)/$(ARTIFACT):bin/$(ARTIFACT)
else ifeq ($(PROJ_TYPE),lib)
    __gcc_mk_dist_files__ := $(O_BUILD_DIR)/$(ARTIFACT):lib/$(ARTIFACT)
endif
__gcc_mk_dist_files__ := $(call FN_UNIQUE,$(__gcc_mk_dist_files__) $(DIST_FILES))

# Each entry (either DIST_DIR or DIST_FILE) has the syntax: src:destPathInDistDir

# Autixiliary function to adjust a distribution directory entry in DIST_DIRS.
# Syntax: $(call __gcc_mk_fn_dist_adjust_dir_entry__,distDirEntry)
__gcc_mk_fn_dist_adjust_dir_entry__ = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):)

# Autixiliary function to adjust a distribution file entry in DIST_FILES.
# Syntax: $(call __gcc_mk_fn_dist_adjust_file_entry__,distFileEntry)
__gcc_mk_fn_dist_adjust_file_entry__ = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):$(notdir $(1)))

__gcc_mk_dist_dirs__ := $(call FN_UNIQUE,$(foreach distDirEntry,$(__gcc_mk_dist_dirs__),$(call __gcc_mk_fn_dist_adjust_dir_entry__,$(distDirEntry))))

DIST_DIRS := $(__gcc_mk_dist_dirs__)

__gcc_mk_dist_files__ := $(__gcc_mk_dist_files__) $(foreach distDirEntry,$(__gcc_mk_dist_dirs__),$(foreach distFile,$(call FN_FIND_FILES,$(call FN_TOKEN,$(distDirEntry),:,1)),$(call FN_TOKEN,$(distDirEntry),:,1)/$(distFile):$(if $(call FN_TOKEN,$(distDirEntry),:,2),$(call FN_TOKEN,$(distDirEntry),:,2)/,)$(distFile)))
__gcc_mk_dist_files__ := $(call FN_UNIQUE,$(foreach distFileEntry,$(__gcc_mk_dist_files__),$(call __gcc_mk_fn_dist_adjust_file_entry__,$(distFileEntry))))
__gcc_mk_dist_files__ := $(call FN_UNIQUE,$(foreach distFileEntry,$(__gcc_mk_dist_files__),$(call FN_TOKEN,$(distFileEntry),:,1):$(O_DIST_DIR)/$(call FN_TOKEN,$(distFileEntry),:,2)))

DIST_FILES := $(__gcc_mk_dist_files__)

# Template for distribution artifacts targets
# $(call __gcc_mk_dist_deps_template__,src,dest)
define __gcc_mk_dist_deps_template__
__gcc_mk_dist_deps__ += $(2)

$(2): $(1)
	@echo [DIST] $$@
	@mkdir -p $$(dir $$@)
	$(VERBOSE)/bin/cp $$< $$@
endef

$(foreach distFileEntry,$(__gcc_mk_dist_files__),$(eval $(call __gcc_mk_dist_deps_template__,$(call FN_TOKEN,$(distFileEntry),:,1),$(call FN_TOKEN,$(distFileEntry),:,2))))
__gcc_mk_dist_deps__ := $(call FN_UNIQUE,$(__gcc_mk_dist_deps__))

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

--__gcc_mk_pre_dist__: build $(PRE_DIST_DEPS) ;

ifneq ($(DIST_MARKER),)
    $(O)/$(DIST_MARKER): $(__gcc_mk_dist_deps__)
	    @touch $@

    .PHONY: --__gcc_mk_dist__
    --__gcc_mk_dist__: --__gcc_mk_pre_dist__ $(O)/$(DIST_MARKER) ;
else
    .PHONY: --__gcc_mk_dist__
    --__gcc_mk_dist__: --__gcc_mk_pre_dist__ $(__gcc_mk_dist_deps__) ;
endif

.PHONY: --__gcc_mk_post_dist__
--__gcc_mk_post_dist__: --__gcc_mk_dist__ $(POST_DIST_DEPS) ;

.PHONY: dist
dist: --__gcc_mk_post_dist__ ;
# ==============================================================================

undefine __gcc_mk_libs_template1__
undefine __gcc_mk_libs_has_lib_dir__
undefine __gcc_mk_libs_ldflags__
undefine __gcc_mk_libs_fn_lib_name__
undefine __gcc_mk_libs_fn_lib_dir__
undefine __gcc_mk_libs_template__
undefine __gcc_mk_libs_fn_template__
undefine __gcc_mk_origin_as__
undefine __gcc_mk_origin_ar__
undefine __gcc_mk_origin_cc__
undefine __gcc_mk_origin_cxx__
undefine __gcc_mk_is_cpp_project__
undefine __gcc_mk_ld__
undefine __gcc_mk_origin_ld__
undefine __gcc_mk_cflags__
undefine __gcc_mk_cxxflags__
undefine __gcc_mk_asflags__
undefine __gcc_mk_ldflags__
undefine __gcc_mk_include_flags__
undefine __gcc_mk_obj_suffix__
undefine __gcc_mk_obj_files__
undefine __gcc_mk_dep_files__
undefine __gcc_mk_cxx_template__
undefine __gcc_mk_as_template__
undefine __gcc_mk_dist_dirs__
undefine __gcc_mk_dist_files__
undefine __gcc_mk_fn_dist_adjust_dir_entry__
undefine __gcc_mk_fn_dist_adjust_file_entry__
undefine __gcc_mk_dist_deps_template__
undefine __gcc_mk_dist_deps__

endif # ifndef __gcc_mk__
