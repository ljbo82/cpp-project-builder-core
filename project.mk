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

# Common definitions

ifndef __project_mk__
__project_mk__ := 1

__project_mk_self_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))

include $(__project_mk_self_dir__)functions.mk

# Checks for whitespace in CWD -------------------------------------------------
ifneq ($(words $(shell pwd)),1)
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# Enable/Disable verbose mode --------------------------------------------------
V ?= 0
ifeq ($(V),)
    $(error [V] Missing value)
endif
ifneq ($(call FN_INVALID_OPTION,$(V),0 1),)
    $(error [V] Invalid value: $(V))
endif
ifdef O_VERBOSE
    $(error [O_VERBOSE] Reserved variable)
endif
O_VERBOSE = $(if $(filter 0,$(V)),@,)
# ------------------------------------------------------------------------------

# Project type -----------------------------------------------------------------
ifeq ($(PROJ_TYPE),)
    $(error [PROJ_TYPE] Missing value)
endif
ifneq ($(origin PROJ_TYPE),file)
    $(error [PROJ_TYPE] Not defined in a makefile (origin: $(origin PROJ_TYPE)))
endif
ifneq ($(call FN_INVALID_OPTION,$(PROJ_TYPE),app lib custom),)
    $(error [PROJ_TYPE] Invalid value: $(PROJ_TYPE))
endif
# ------------------------------------------------------------------------------

# Project name -----------------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifeq ($(PROJ_NAME),)
        $(error [PROJ_NAME] Missing value)
    endif
    ifneq ($(origin PROJ_NAME),file)
        $(error [PROJ_NAME] Not defined in a makefile (origin: $(origin PROJ_NAME)))
    endif
    ifneq ($(words $(PROJ_NAME)),1)
        $(error [PROJ_NAME] Value cannot have whitespaces: $(PROJ_NAME))
    endif
endif
# ------------------------------------------------------------------------------

# Project version --------------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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
endif
# ------------------------------------------------------------------------------

# Debug / release --------------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    DEBUG ?= 0
    ifeq ($(DEBUG),)
        $(error [DEBUG] Missing value)
    endif
    ifneq ($(call FN_INVALID_OPTION,$(DEBUG),0 1),)
        $(error [DEBUG] Invalid value: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# Output directory -------------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    O ?= output
    ifeq ($(O),)
        $(error [O] Missing value)
    endif
    ifneq ($(words $(O)),1)
        $(error [O] Value cannot have whitespaces: $(O))
    endif
endif
# ------------------------------------------------------------------------------

# Build sub-directory ----------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifneq ($(BUILD_SUBDIR),)
        ifneq ($(words $(BUILD_SUBDIR)),1)
            $(error [BUILD_SUBDIR] Value cannot have whitespaces: $(BUILD_SUBDIR))
        endif
        $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(BUILD_SUBDIR)),,$(error [BUILD_SUBDIR] Invalid path: $(BUILD_SUBDIR)))
    endif
    ifdef O_BUILD_DIR
        $(error [O_BUILD_DIR] Reserved variable)
    else
        O_BUILD_DIR := $(O)/build
        ifneq ($(BUILD_SUBDIR),)
            O_BUILD_DIR := $(O_BUILD_DIR)/$(BUILD_SUBDIR)
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Distribution sub-directory ---------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifneq ($(DIST_SUBDIR),)
        ifneq ($(words $(DIST_SUBDIR)),1)
            $(error [DIST_SUBDIR] Value cannot have whitespaces: $(DIST_SUBDIR))
        endif
        $(if $(call FN_IS_INSIDE_DIR,$(CURDIR),$(DIST_SUBDIR)),,$(error [DIST_SUBDIR] Invalid path: $(DIST_SUBDIR)))
    endif
    ifdef O_DIST_DIR
        $(error [O_DIST_DIR] Reserved variable)
    else
        O_DIST_DIR := $(O)/dist
        ifneq ($(DIST_SUBDIR),)
            O_DIST_DIR := $(DIST_SUBDIR)/$(DIST_SUBDIR)
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Source directories -----------------------------------------------------------
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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
            SRC_DIRS += src
        endif
    endif
endif
# ------------------------------------------------------------------------------

# Manages target host ----------------------------------------------------------
include $(__project_mk_self_dir__)hosts.mk
# ------------------------------------------------------------------------------

# Strips release build ---------------------------------------------------------
# NOTE: A host layer may have set STRIP_RELEASE
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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
endif
# ------------------------------------------------------------------------------

# Optimizes release build ------------------------------------------------------
# NOTE: A host layer may have set OPTIMIZE_RELEASE and RELEASE_OPTIMIZATION_LEVEL
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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
endif
# ------------------------------------------------------------------------------

# LIB_TYPE ----------------------------------------------------------------------
# NOTE: A host layer may have set LIB_TYPE
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ifeq ($(PROJ_TYPE),lib)
        LIB_TYPE ?= shared
        ifeq ($(LIB_TYPE),)
            $(error [LIB_TYPE] Missing value)
        endif
        ifneq ($(call FN_INVALID_OPTION,$(LIB_TYPE),shared static),)
            $(error [LIB_TYPE] Invalid value: $(LIB_TYPE))
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ARTIFACT ---------------------------------------------------------------------
# NOTE: A host layer may have set ARTIFACT
ifneq ($(filter app lib,$(PROJ_TYPE)),)
    ARTIFACT ?= a.out
    ifeq ($(ARTIFACT),)
        $(error [ARTIFACT] Missing value)
    endif
    ifneq ($(words $(ARTIFACT)),1)
        $(error [ARTIFACT] Value cannot have whitespaces: $(ARTIFACT))
    endif
endif
# ------------------------------------------------------------------------------

# Identify source files --------------------------------------------------------
# NOTE: Source files must be searched after host layers
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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
endif
# ------------------------------------------------------------------------------

# Include directories ----------------------------------------------------------
# NOTE: Include directories must be managed after host layers
ifneq ($(filter app lib,$(PROJ_TYPE)),)
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

    ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
        ifneq ($(wildcard include),)
            INCLUDE_DIRS += include
        endif
    endif

    INCLUDE_DIRS := $(call FN_UNIQUE,$(SRC_DIRS) $(INCLUDE_DIRS))
endif
# ------------------------------------------------------------------------------

# LIBS -------------------------------------------------------------------------
ifdef LIBS
    ifneq ($(origin LIBS),file)
        $(error [LIBS] Not defined in a makefile (origin: $(origin LIBS)))
    endif
endif

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

# LAZY_INCLUDES -------------------------------------------------------------------------
ifneq ($(LAZY_INCLUDES),)
    ifneq ($(origin LAZY_INCLUDES),file)
        $(error [LAZY_INCLUDES] Not defined in a makefile (origin: $(origin LAZY_INCLUDES)))
    endif
    include $(LAZY_INCLUDES)
endif
# ------------------------------------------------------------------------------

# print-vars ===================================================================
VARS ?= $(sort DEBUG HOST DIST_MARKER O O_BUILD_DIR O_DIST_DIR V DIST_DIRS DIST_FILES INCLUDE_DIRS LIB_TYPE POST_BUILD_DEPS POST_CLEAN_DEPS POST_DIST_DEPS PRE_BUILD_DEPS PRE_CLEAN_DEPS PRE_DIST_DEPS PROJ_NAME PROJ_TYPE PROJ_VERSION SRC_DIRS SRC_FILES AR AS ASFLAGS CC CFLAGS CROSS_COMPILE CXX CXXFLAGS LD LDFLAGS HOSTS_DIRS OPTIMIZE_RELEASE RELEASE_OPTIMIZATION_LEVEL SKIP_DEFAULT_INCLUDE_DIR SKIP_DEFAULT_SRC_DIR SKIPPED_SRC_DIRS SKIPPED_SRC_FILES STRIP_RELEASE ARTIFACT LIBS)
.PHONY: print-vars
print-vars:
    ifeq ($(VARS),)
	    $(error [VARS] Missing value)
    endif
	$(foreach varName,$(VARS),$(info $(varName) = $($(varName))))
	@printf ''
# ==============================================================================

undefine __project_mk_src_file_filter__
undefine __project_mk_invalid_src_files__

undefine __project_mk_libs_template1__
undefine __project_mk_libs_has_lib_dir__
undefine __project_mk_libs_ldflags__
undefine __project_mk_libs_fn_lib_name__
undefine __project_mk_libs_fn_lib_dir__
undefine __project_mk_libs_template__
undefine __project_mk_libs_fn_template__

undefine __project_mk_self_dir__

endif # ifndef __project_mk__
