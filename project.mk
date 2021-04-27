# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

ifndef _include_project_mk
_include_project_mk := 1

# ------------------------------------------------------------------------------
__selfDir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__selfDir)defs.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
SRC_DIRS := $(sort $(SRC_DIRS))
srcFiles := $(sort $(strip $(foreach srcDir, $(SRC_DIRS), $(shell find $(srcDir) -type f -name *.c -or -name *.cpp -or -name *.S 2> /dev/null))))
ifeq ($(DEBUG), 1)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            objSuffix := .pic.dbg.o
        else
            objSuffix := .dbg.o
        endif
    else
        objSuffix := .dbg.o
    endif
else
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            objSuffix := .pic.o
        else
            objSuffix := .o
        endif
    else
        objSuffix := .o
    endif
endif
objFiles := $(srcFiles:%=$(buildDir)/%$(objSuffix))
depFiles := $(objFiles:.o=.d)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(wildcard $(defaultIncludeDir)), )
    ifeq ($(PROJ_TYPE), lib)
        _postDistDeps += $(foreach distHeader, $(shell find $(defaultIncludeDir) -type f -name *.h -or -name *.hpp 2> /dev/null), $(distDir)/$(distHeader))
    endif
endif
INCLUDE_DIRS := $(sort $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
_cFlags   += -Wall
_cxxFlags += -Wall
ifeq ($(DEBUG), 1)
    _cFlags   += -g3
    _cxxFlags += -g3
    _asFlags  += -g3
endif

_includeFlags += $(strip $(foreach srcDir, $(SRC_DIRS), -I$(srcDir)))
_includeFlags += $(strip $(foreach includeDir, $(INCLUDE_DIRS), -I$(includeDir)))

ifeq ($(PROJ_TYPE), lib)
    ifeq ($(LIB_TYPE), shared)
        _cFlags   += -fPIC
        _cxxFlags += -fPIC
        _ldFlags  += -shared
    endif
endif

_arFlags += rcs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
isCppProject := $(strip $(foreach srcDir, $(SRC_DIRS), $(shell find $(srcDir) -type f -name *.cpp 2> /dev/null)))
ifeq ($(isCppProject), )
    isCppProject = $(strip $(foreach includeDir, $(INCLUDE_DIRS), $(shell find $(includeDir) -type f -name *.hpp 2> /dev/null)))
endif

ifeq ($(isCppProject), )
    isCppProject := 0
else
    isCppProject := 1
endif

CC := gcc
ifeq ($(isCppProject), 0)
    # Pure C project
    LD := gcc
else
    # C/C++ project
    LD := $(CXX)
endif
# ------------------------------------------------------------------------------

# ALL ==========================================================================
.PHONY: all
all: dist
# ==============================================================================

# BUILD ========================================================================
.PHONY: build
build: post-build

.PHONY: pre-build
pre-build: $(PRE_BUILD_DEPS)
    ifneq ($(PRE_BUILD), )
	    @printf "$(nl)[PRE-BUILD]\n"
	    $(v)$(PRE_BUILD)
    endif

.PHONY: post-build
post-build: pre-build $(BUILD_DEPS) $(buildDir)/$(artifactName) $(_postBuildDeps) $(POST_BUILD_DEPS)
    ifneq ($(POST_BUILD), )
	    @printf "$(nl)[POST-BUILD]\n"
	    $(v)$(POST_BUILD)
    endif
# ==============================================================================

# CLEAN ========================================================================
.PHONY: clean
clean: post-clean

.PHONY: pre-clean
pre-clean:
    ifneq ($(PRE_CLEAN), )
	    @printf "$(nl)[PRE-CLEAN]\n"
	    $(v)$(PRE_CLEAN)
    endif

.PHONY: post-clean
post-clean: pre-clean
	@printf "$(nl)[CLEAN]\n"
	$(v)rm -rf $(BUILD_DIR_BASE) $(DIST_DIR_BASE)
    ifneq ($(POST_CLEAN), )
	    @printf "$(nl)[POST-CLEAN]\n"
	    $(v)$(POST_CLEAN)
    endif
# ==============================================================================

# DIST =========================================================================
.PHONY: dist
dist: post-dist

.PHONY: pre-dist
pre-dist: $(PRE_DIST_DEPS)
    ifneq ($(PRE_DIST), )
	    @printf "$(nl)[PRE-DIST]\n"
	    $(v)$(PRE_DIST)
    endif

.PHONY: post-dist
post-dist: pre-dist $(DIST_DEPS) build $(_postDistDeps) $(POST_DIST_DEPS)
    ifneq ($(POST_DIST), )
	    @printf "$(nl)[POST-DIST]\n"
	    $(v)$(POST_DIST)
    endif
# ==============================================================================

# _postDistDeps ================================================================
$(distDir)/$(defaultIncludeDir)/%.h : $(defaultIncludeDir)/%.h
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(dir $@)
	$(v)ln $< $@
# ==============================================================================

# ==============================================================================
$(buildDir)/$(artifactName): $(objFiles)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
	        @printf "$(nl)[LD] $@\n"
	        $(v)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(objFiles) $(_ldFlags) $(LDFLAGS))
        else
	        @printf "$(nl)[AR] $@\n"
	        $(v)$(CROSS_COMPILE)$(AR) $(strip $(_arFlags) $@ $(objFiles))
        endif
    else
	    @printf "$(nl)[LD] $@\n"
	    $(v)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(objFiles) $(_ldFlags) $(LDFLAGS))
    endif
# ==============================================================================

# ==============================================================================
$(buildDir)/%.c$(objSuffix): %.c
	@printf "$(nl)[CC] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CC) $(strip $(_cFlags) -MMD $(CFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

# ==============================================================================
$(buildDir)/%.cpp$(objSuffix): %.cpp
	@printf "$(nl)[CXX] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CXX) $(strip $(_cxxFlags) -MMD -MP $(CXXFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

# ==============================================================================
$(buildDir)/%.S$(objSuffix): %.S
	@printf "$(nl)[AS] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(AS) $(strip $(_asFlags) -MMD $(ASFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

-include $(_deps)

undefine __selfDir

endif # _include_project_mk

