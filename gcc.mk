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

ifndef gcc_mk
gcc_mk := 1

ifndef project_mk
    $(error This file cannot be manually included)
endif

# Libs -------------------------------------------------------------------------
ifdef LIBS
    ifneq ($(origin LIBS),file)
        $(error [LIBS] Not defined in a makefile (origin: $(origin LIBS)))
    endif
endif

ifdef DEPS
    $(error [DEPS] Reserved variable)
endif

#$(call gcc_mk_libs_template1,<lib_name>,[lib_dir])
define gcc_mk_libs_template1
gcc_mk_libs_has_lib_dir := $$(if $$(or $$(gcc_mk_libs_has_lib_dir),$(2)),1,)
gcc_mk_libs_ldflags += -l$(1)
gcc_mk_libs_proj_dirs := $$(strip $$(gcc_mk_libs_proj_dirs) $(2))

$(if $(2),PRE_BUILD_DEPS += $$(O)/libs/$(1).marker,)
$(if $(2),--$(1):,)
$(if $(2),	$$(VERBOSE)$$(MAKE) -C $(2) O=$$(call FN_REL_DIR,$(2),$$(O)/libs) BUILD_SUBDIR=$(1) DIST_MARKER=$(1).marker,)
$(if $(2),$$(O)/libs/$(1).marker: --$(1) ;,)

endef

# $(call gcc_mk_libs_fn_lib_name,<lib_entry>)
gcc_mk_libs_fn_lib_name = $(word 1, $(subst :, ,$(1)))

# $(call gcc_mk_libs_fn_lib_dir,<lib_entry>)
gcc_mk_libs_fn_lib_dir = $(word 2, $(subst :, ,$(1)))

# $(call gcc_mk_libs_template,<lib_entry>)
gcc_mk_libs_template = $(call gcc_mk_libs_template1,$(call gcc_mk_libs_fn_lib_name,$(1)),$(call gcc_mk_libs_fn_lib_dir,$(1)))

# $(call gcc_mk_libs_fn_template,<lib_entry>)
gcc_mk_libs_fn_template = $(eval $(call gcc_mk_libs_template,$(1)))

$(foreach lib,$(LIBS),$(call gcc_mk_libs_fn_template,$(lib)))
ifeq ($(gcc_mk_libs_has_lib_dir),1)
    DEPS := $(strip $(gcc_mk_libs_ldflags) `$(foreach lib_proj,$(strip $(gcc_mk_libs_proj_dirs)),$$(MAKE) -C $(lib_proj) deps;))`
    ifneq ($(MAKECMDGOALS),deps)
        ifneq ($(filter app lib,$(PROJ_TYPE)),)
            INCLUDE_DIRS += $(O)/libs/dist/include
            LDFLAGS := $(LDFLAGS) -L$(O)/libs/dist/lib $(DEPS)
        endif
    endif
else
    ifneq ($(MAKECMDGOALS),deps)
        ifneq ($(filter app lib,$(PROJ_TYPE)),)
            LDFLAGS := $(LDFLAGS) $(gcc_mk_libs_ldflags)
        endif
    endif
endif
# ------------------------------------------------------------------------------

ifneq ($(MAKECMDGOALS),deps)
    ifneq ($(filter app lib,$(PROJ_TYPE)),)
        # Compiler management --------------------------------------------------
        # AS
        ifndef AS
            AS := as
        else
            ifeq ($(origin AS),default)
                AS := as
            else ifeq ($(AS),)
                $(error [AS] Missing value)
            endif
        endif

        # CC
        ifndef CC
            CC := gcc
        else
            ifeq ($(origin CC),default)
                CC := gcc
            else ifeq ($(CC),)
                $(error [CC] Missing value)
            endif
        endif

        # CXX
        ifndef CXX
            CXX := g++
        else
            ifeq ($(origin CXX),default)
                CXX := g++
            else ifeq ($(CXX),)
                $(error [CXX] Missing value)
            endif
        endif

        # AR
        ifndef AR
            AR := ar
        else
            ifeq ($(origin AR),default)
                AR := ar
            else ifeq ($(AR),)
                $(error [AR] Missing value)
            endif
        endif

        # LD
        gcc_mk_is_cpp_project := $(strip $(filter %.cpp %.cxx %.cc,$(SRC_FILES)))
        ifeq ($(gcc_mk_is_cpp_project),)
            gcc_mk_is_cpp_project := $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name '*.hpp' -or -name '*.hxx' 2> /dev/null)))
        endif

        ifeq ($(gcc_mk_is_cpp_project),)
            # Pure C project
            gcc_mk_ld := gcc
        else
            # C/C++ project
            gcc_mk_ld := g++
        endif

        ifndef LD
            LD := $(gcc_mk_ld)
        else
            ifeq ($(origin LD),default)
                LD := $(gcc_mk_ld)
            else ifeq ($(LD),)
                $(error [LD] Missing value)
            endif
        endif

        gcc_mk_cflags += -Wall
        gcc_mk_cxxflags += -Wall

        ifneq ($(DEBUG),0)
            gcc_mk_cflags += -g3
            gcc_mk_cxxflags += -g3
            gcc_mk_asflags += -g3
        else
            ifneq ($(OPTIMIZE_RELEASE),0)
                gcc_mk_cflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
                gcc_mk_cxxflags += -O$(RELEASE_OPTIMIZATION_LEVEL)
            endif

            ifneq ($(STRIP_RELEASE),0)
                gcc_mk_cflags += -s
                gcc_mk_cxxflags += -s
                gcc_mk_ldflags += -s
            endif
        endif

        ifeq ($(PROJ_TYPE),lib)
            ifeq ($(LIB_TYPE),shared)
                gcc_mk_cflags += -fPIC
                gcc_mk_cxxflags += -fPIC
                gcc_mk_ldflags += -shared
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

        gcc_mk_include_flags := $(strip $(foreach includeDir,$(INCLUDE_DIRS),-I$(includeDir)))

        CFLAGS   := -MMD -MP $(gcc_mk_include_flags) $(gcc_mk_cflags) $(CFLAGS) $(EXTRA_CFLAGS)
        CXXFLAGS := -MMD -MP $(gcc_mk_include_flags) $(gcc_mk_cxxflags) $(CXXFLAGS) $(EXTRA_CXXFLAGS)
        ASFLAGS  := -MMD -MP $(gcc_mk_include_flags) $(gcc_mk_asflags) $(ASFLAGS) $(EXTRA_ASFLAGS)
        ARFLAGS  := rcs $(ARFLAGS) $(EXTRA_ARFLAGS)
        LDFLAGS  := $(gcc_mk_ldflags) $(LDFLAGS) $(DEPS) $(EXTRA_LDFLAGS)
        # ----------------------------------------------------------------------
    endif
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

.PHONY: --gcc_mk_pre_clean
--gcc_mk_pre_clean: $(PRE_CLEAN_DEPS) ;

.PHONY: --gcc_mk_clean
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    --gcc_mk_clean: --gcc_mk_pre_clean
	    $(VERBOSE)rm -rf $(O)
else ifeq ($(PROJ_TYPE),custom)
    ifneq ($(CUSTOM_CLEAN_CMD),)
        ifneq ($(origin CUSTOM_CLEAN_CMD),file)
            $(error [CUSTOM_CLEAN_CMD] Not defined in a makefile (origin: $(origin CUSTOM_CLEAN_CMD)))
        endif
        --gcc_mk_clean: --gcc_mk_pre_clean
	        $(VERBOSE)$(CUSTOM_CLEAN_CMD)
    else
        --gcc_mk_clean: --gcc_mk_pre_clean ;
    endif
endif

.PHONY: --gcc_mk_post_clean
--gcc_mk_post_clean: --gcc_mk_clean $(POST_CLEAN_DEPS) ;

.PHONY: clean
clean: --gcc_mk_post_clean ;
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
            gcc_mk_obj_suffix := .lo
        else
            gcc_mk_obj_suffix := .o
        endif
    else ifeq ($(PROJ_TYPE),app)
        gcc_mk_obj_suffix := .o
    endif

    gcc_mk_obj_files := $(SRC_FILES:%=$(O_BUILD_DIR)/%$(gcc_mk_obj_suffix))

    ifeq ($(PROJ_TYPE),lib)
        # NOTE: When enabled, '-fPIC' will be set for both C and C++ source files
        ifneq ($(filter -fPIC,$(CFLAGS) $(CXXFLAGS)),)
            gcc_mk_dep_files := $(gcc_mk_obj_files:.lo=.d)
        else
            gcc_mk_dep_files := $(gcc_mk_obj_files:.o=.d)
        endif
    else ifeq ($(PROJ_TYPE),app)
        gcc_mk_dep_files := $(gcc_mk_obj_files:.o=.d)
    endif

    .PHONY: --gcc_mk_pre_build_check
    --gcc_mk_pre_build_check:
        ifneq ($(HOST),$(NATIVE_HOST))
            ifeq ($(origin CROSS_COMPILE),undefined)
	            $(error [CROSS_COMPILE] Missing value for HOST $(HOST))
            endif
        endif

    define gcc_mk_artifact_target
    $(O_BUILD_DIR)/$(ARTIFACT): $(PRE_BUILD_DEPS) $(gcc_mk_obj_files)
        ifeq ($(PROJ_TYPE),lib)
            ifeq ($(LIB_TYPE),shared)
	            @echo [LD] $$@
	            $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $$@ $(gcc_mk_obj_files) $(LDFLAGS))
            else ifeq ($(LIB_TYPE),static)
	            @echo [AR] $$@
	            $(VERBOSE)$(CROSS_COMPILE)$(AR) $(strip $(ARFLAGS) $$@ $(gcc_mk_obj_files))
            endif
        else ifeq ($(PROJ_TYPE),app)
	        @echo [LD] $$@
	        $(VERBOSE)$(CROSS_COMPILE)$(LD) $(strip -o $$@ $(gcc_mk_obj_files) $(LDFLAGS))
        endif
    endef
    $(eval $(gcc_mk_artifact_target))
    undefine gcc_mk_artifact_target

    .PHONY: build
    build: --gcc_mk_pre_build_check $(O_BUILD_DIR)/$(ARTIFACT) $(POST_BUILD_DEPS) ;

    # C sources ----------------------------------------------------------------
    $(O_BUILD_DIR)/%.c$(gcc_mk_obj_suffix): %.c
	    @echo [CC] $@
	    @mkdir -p $(dir $@)
	    $(VERBOSE)$(CROSS_COMPILE)$(CC) $(strip $(CFLAGS) -c $< -o $@)
    # --------------------------------------------------------------------------

    # C++ sources --------------------------------------------------------------
    define gcc_mk_cxx_template =
    $(O_BUILD_DIR)/%.$(1)$(gcc_mk_obj_suffix): %.$(1)
	    @echo [CXX] $$@
	    @mkdir -p $$(dir $$@)
	    $(VERBOSE)$(CROSS_COMPILE)$(CXX) $$(strip $(CXXFLAGS) -c $$< -o $$@)
    endef

    $(eval $(call gcc_mk_cxx_template,cpp))
    $(eval $(call gcc_mk_cxx_template,cxx))
    $(eval $(call gcc_mk_cxx_template,cc))
    # --------------------------------------------------------------------------

    # Assembly sources ---------------------------------------------------------
    define gcc_mk_as_template =
    $(O_BUILD_DIR)/%.$(1)$(gcc_mk_obj_suffix): %.$(1)
	    @echo [AS] $$@
	    @mkdir -p $$(dir $$@)
	    $(VERBOSE)$(CROSS_COMPILE)$(AS) $$(strip $(ASFLAGS) -c $$< -o $$@)
    endef

    $(eval $(call gcc_mk_as_template,s))
    $(eval $(call gcc_mk_as_template,S))
    # --------------------------------------------------------------------------

    -include $(gcc_mk_dep_files)
else ifeq ($(PROJ_TYPE), custom)
    .PHONY: --gcc_mk_pre_build
    --gcc_mk_pre_build: $(PRE_BUILD_DEPS) ;

    .PHONY: --gcc_mk_build
    ifeq ($(CUSTOM_BUILD_CMD),)
        --gcc_mk_build: --gcc_mk_pre_build ;
    else
        --gcc_mk_build: --gcc_mk_pre_build
	        $(VERBOSE)$(CUSTOM_BUILD_CMD)
    endif

    .PHONY: --gcc_mk_post_build
    --gcc_mk_post_build: --gcc_mk_build $(POST_BUILD_DEPS) ;

    .PHONY: build
    build: --gcc_mk_post_build ;
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
            gcc_mk_dist_dirs := include:include
        endif
    endif
endif

gcc_mk_dist_dirs := $(call FN_UNIQUE,$(gcc_mk_dist_dirs) $(DIST_DIRS))

ifdef DIST_FILES
    ifneq ($(origin DIST_FILES),file)
        $(error [DIST_FILES] Not defined in a makefile (origin: $(origin DIST_FILES)))
    endif
endif
ifeq ($(PROJ_TYPE),app)
    gcc_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):bin/$(ARTIFACT)
else ifeq ($(PROJ_TYPE),lib)
    gcc_mk_dist_files := $(O_BUILD_DIR)/$(ARTIFACT):lib/$(ARTIFACT)
endif
gcc_mk_dist_files := $(call FN_UNIQUE,$(gcc_mk_dist_files) $(DIST_FILES))

# Each entry (either DIST_DIR or DIST_FILE) has the syntax: src:destPathInDistDir

# Autixiliary function to adjust a distribution directory entry in DIST_DIRS.
# Syntax: $(call gcc_mk_fn_dist_adjust_dir_entry,distDirEntry)
gcc_mk_fn_dist_adjust_dir_entry = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):)

# Autixiliary function to adjust a distribution file entry in DIST_FILES.
# Syntax: $(call gcc_mk_fn_dist_adjust_file_entry,distFileEntry)
gcc_mk_fn_dist_adjust_file_entry = $(if $(call FN_TOKEN,$(1),:,2),$(1),$(1):$(notdir $(1)))

gcc_mk_dist_dirs := $(call FN_UNIQUE,$(foreach distDirEntry,$(gcc_mk_dist_dirs),$(call gcc_mk_fn_dist_adjust_dir_entry,$(distDirEntry))))

DIST_DIRS := $(gcc_mk_dist_dirs)

gcc_mk_dist_files := $(gcc_mk_dist_files) $(foreach distDirEntry,$(gcc_mk_dist_dirs),$(foreach distFile,$(call FN_FIND_FILES,$(call FN_TOKEN,$(distDirEntry),:,1)),$(call FN_TOKEN,$(distDirEntry),:,1)/$(distFile):$(if $(call FN_TOKEN,$(distDirEntry),:,2),$(call FN_TOKEN,$(distDirEntry),:,2)/,)$(distFile)))
gcc_mk_dist_files := $(call FN_UNIQUE,$(foreach distFileEntry,$(gcc_mk_dist_files),$(call gcc_mk_fn_dist_adjust_file_entry,$(distFileEntry))))
gcc_mk_dist_files := $(call FN_UNIQUE,$(foreach distFileEntry,$(gcc_mk_dist_files),$(call FN_TOKEN,$(distFileEntry),:,1):$(O_DIST_DIR)/$(call FN_TOKEN,$(distFileEntry),:,2)))

DIST_FILES := $(gcc_mk_dist_files)

# Template for distribution artifacts targets
# $(call gcc_mk_dist_deps_template,src,dest)
define gcc_mk_dist_deps_template
gcc_mk_dist_deps += $(2)

$(2): $(1)
	@echo [DIST] $$@
	@mkdir -p $$(dir $$@)
	$(VERBOSE)/bin/cp $$< $$@
endef

$(foreach distFileEntry,$(gcc_mk_dist_files),$(eval $(call gcc_mk_dist_deps_template,$(call FN_TOKEN,$(distFileEntry),:,1),$(call FN_TOKEN,$(distFileEntry),:,2))))
gcc_mk_dist_deps := $(call FN_UNIQUE,$(gcc_mk_dist_deps))

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

--gcc_mk_pre_dist: build $(PRE_DIST_DEPS) ;

ifneq ($(DIST_MARKER),)
    $(O)/$(DIST_MARKER): $(gcc_mk_dist_deps)
	    @touch $@

    .PHONY: --gcc_mk_dist
    --gcc_mk_dist: --gcc_mk_pre_dist $(O)/$(DIST_MARKER) ;
else
    .PHONY: --gcc_mk_dist
    --gcc_mk_dist: --gcc_mk_pre_dist $(gcc_mk_dist_deps) ;
endif

.PHONY: --gcc_mk_post_dist
--gcc_mk_post_dist: --gcc_mk_dist $(POST_DIST_DEPS) ;

.PHONY: dist
dist: --gcc_mk_post_dist ;
# ==============================================================================

undefine gcc_mk_libs_template1
undefine gcc_mk_libs_has_lib_dir
undefine gcc_mk_libs_ldflags
undefine gcc_mk_libs_proj_dirs
undefine gcc_mk_libs_fn_lib_name
undefine gcc_mk_libs_fn_lib_dir
undefine gcc_mk_libs_template
undefine gcc_mk_libs_fn_template
undefine gcc_mk_is_cpp_project
undefine gcc_mk_ld
undefine gcc_mk_cflags
undefine gcc_mk_cxxflags
undefine gcc_mk_asflags
undefine gcc_mk_ldflags
undefine gcc_mk_include_flags
undefine gcc_mk_obj_suffix
undefine gcc_mk_obj_files
undefine gcc_mk_dep_files
undefine gcc_mk_cxx_template
undefine gcc_mk_as_template
undefine gcc_mk_dist_dirs
undefine gcc_mk_dist_files
undefine gcc_mk_fn_dist_adjust_dir_entry
undefine gcc_mk_fn_dist_adjust_file_entry
undefine gcc_mk_dist_deps_template
undefine gcc_mk_dist_deps

endif # ifndef gcc_mk
