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
_project_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
include $(_project_mk_dir)functions.mk
include $(_project_mk_dir)native_host.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
defaultLibType           := shared
defaultProjVersion       := 0.1.0
defaultDebug             := 0
defaultV                 := 0
defaultBuildDirBase      := build
defaultDistDirBase       := dist
defaultSrcDir            := src
defaultIncludeDir        := include
defaultHostsDir          := hosts
defaultHostMkRequired    := 0
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_NAME),  )
    $(error Missing PROJ_NAME)
endif

ifneq (1, $(words $(PROJ_NAME)))
    $(error PROJ_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), )
    $(error Missing PROJ_TYPE)
endif
ifneq ($(PROJ_TYPE), app)
    ifneq ($(PROJ_TYPE), lib)
        $(error Unsupported PROJ_TYPE: $(PROJ_TYPE))
    else
        ifeq ($(LIB_TYPE), )
            LIB_TYPE := $(defaultLibType)
        endif
        ifneq ($(LIB_TYPE), shared)
            ifneq ($(LIB_TYPE), static)
                $(error Unsupported LIB_TYPE: $(LIB_TYPE))
            endif
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_VERSION), )
    PROJ_VERSION := $(defaultProjVersion)
endif

ifeq ($(call fn_version_valid, $(PROJ_VERSION)), 0)
    $(error Invalid PROJ_VERSION: $(PROJ_VERSION))
endif

projVersionMajor := $(call fn_version_major, $(PROJ_VERSION))
projVersionMinor := $(call fn_version_minor, $(PROJ_VERSION))
projVersionPatch := $(call fn_version_patch, $(PROJ_VERSION))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DEBUG), )
    DEBUG := $(defaultDebug)
endif
ifneq ($(DEBUG), 0)
    ifneq ($(DEBUG), 1)
        $(error Invalid value for DEBUG: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(V), )
    V := $(defaultV)
endif
ifneq ($(V), 0)
    ifneq ($(V), 1)
        $(error ERROR: Invalid value for V: $(V))
    endif
endif

ifeq ($(V), 0)
    v  := @
    nl :=
else
    v  :=
    nl := \n
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST), )
    ifeq ($(nativeOS), )
        $(error Cannot detect native operating system)
    endif
    ifeq ($(nativeArch), )
        $(error Cannot detect native architecture)
    endif
    hostOS   := $(nativeOS)
    hostArch := $(nativeArch)
    HOST     := $(hostOS)-$(hostArch)
else
    ifeq ($(call fn_host_valid, $(HOST)), 0)
        $(error Invalid HOST: $(HOST))
    endif
    hostOS   := $(call fn_host_os, $(HOST))
    hostArch := $(call fn_host_arch, $(HOST))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(BUILD_DIR_BASE), )
    BUILD_DIR_BASE := $(defaultBuildDirBase)
endif
ifeq ($(BUILD_DIR_NAME), )
    BUILD_DIR_NAME := $(HOST)
endif
buildDir := $(BUILD_DIR_BASE)/$(BUILD_DIR_NAME)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DIST_DIR_BASE), )
    DIST_DIR_BASE := $(defaultDistDirBase)
endif
ifeq ($(DIST_DIR_NAME), )
    DIST_DIR_NAME := $(HOST)
endif
distDir := $(DIST_DIR_BASE)/$(DIST_DIR_NAME)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(wildcard $(defaultSrcDir)), )
    SRC_DIRS += $(defaultSrcDir)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(wildcard $(defaultIncludeDir)), )
    ifeq ($(PROJ_TYPE), lib)
        DIST_INCLUDE_DIRS += $(defaultIncludeDir)
    endif
    INCLUDE_DIRS += $(defaultIncludeDir)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOSTS_DIR), )
    HOSTS_DIR := $(defaultHostsDir)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK_REQUIRED), )
    HOST_MK_REQUIRED := $(defaultHostMkRequired)
endif

ifneq ($(HOST_MK_REQUIRED), 0)
    ifneq ($(HOST_MK_REQUIRED), 1)
        $(error Invalid value for HOST_MK_REQUIRED: $(HOST_MK_REQUIRED))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK), )
    ifneq ($(wildcard $(HOSTS_DIR)/$(HOST).mk), )
        HOST_MK := $(HOSTS_DIR)/$(HOST).mk
    else
        ifneq ($(wildcard $(HOSTS_DIR)/$(hostOS).mk), )
            HOST_MK := $(HOSTS_DIR)/$(hostOS).mk
        else
            HOST_MK :=
        endif
    endif
else
    ifeq ($(wildcard $(HOST_MK)), )
        $(error [HOST_MK] No such file: $(HOST_MK))
    endif
endif

ifneq ($(HOST_MK), )
    include $(HOST_MK)
else
    ifeq ($(HOST_MK_REQUIRED), 1)
        $(error Unsupported HOST: $(HOST))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(BUILDER_HOST_MK), )
    ifneq ($(wildcard $(_project_mk_dir)$(defaultHostsDir)/$(HOST).mk), )
        BUILDER_HOST_MK := $(_project_mk_dir)$(defaultHostsDir)/$(HOST).mk
    else
        ifneq ($(wildcard $(_project_mk_dir)$(defaultHostsDir)/$(hostOS).mk), )
            BUILDER_HOST_MK := $(_project_mk_dir)$(defaultHostsDir)/$(hostOS).mk
        else
            BUILDER_HOST_MK :=
        endif
    endif
else
    ifeq ($(wildcard $(BUILDER_HOST_MK)), )
        $(error [BUILDER_HOST_MK] No such file: $(BUILDER_HOST_MK))
    endif
endif

ifneq ($(BUILDER_HOST_MK), )
    include $(BUILDER_HOST_MK)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK), )
    ifeq ($(BUILDER_HOST_MK), )
        $(error Unsupported HOST: $(HOST))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
SRC_DIRS := $(sort $(SRC_DIRS))
srcFiles := $(sort $(strip $(foreach srcDir, $(SRC_DIRS), $(shell find $(srcDir) -type f -name '*.c' -or -name '*.cpp' -or -name '*.S' 2> /dev/null))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
depFiles := $(objFiles:.o=.d)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), app)
    _postDistDeps += $(distDir)/bin/$(artifactName)
else
    ifeq ($(LIB_TYPE), static)
        _postDistDeps += $(distDir)/lib/$(artifactName)
    else
        _postDistDeps += $(distDir)/lib/$(artifactName)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
INCLUDE_DIRS := $(sort $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), lib)
    DIST_INCLUDE_DIRS := $(sort $(DIST_INCLUDE_DIRS))
    distIncludeFiles := $(strip $(foreach distIncludeDir, $(DIST_INCLUDE_DIRS), $(shell find $(distIncludeDir) -type f -name '*.h' -or -name '*.hpp' 2> /dev/null)))
    _postDistDeps += $(strip $(foreach distIncludeFile, $(distIncludeFiles), $(distDir)/$(distIncludeFile)))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
_cFlags   += -Wall
_cxxFlags += -Wall
ifeq ($(DEBUG), 1)
    _cFlags   += -g3
    _cxxFlags += -g3
    _asFlags  += -g3
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
_includeFlags += $(strip $(foreach srcDir, $(SRC_DIRS), -I$(srcDir)))
ifeq ($(PROJ_TYPE), lib)
    _includeDirs = $(sort $(INCLUDE_DIRS) $(DIST_INCLUDE_DIRS))
else
    _includeDirs = $(INCLUDE_DIRS)
endif
_includeFlags += $(strip $(foreach includeDir, $(_includeDirs), -I$(includeDir)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), lib)
    ifeq ($(LIB_TYPE), shared)
        _cFlags   += -fPIC
        _cxxFlags += -fPIC
        _ldFlags  += -shared
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
ifeq ($(shell sh -c "$(CROSS_COMPILE)gcc -v > /dev/null 2>&1 && echo 1 || echo 0"), 0)
    $(error $(CROSS_COMPILE)gcc is not in PATH)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
.DEFAULT_GOAL := all

.NOTPARALLEL:
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
	    $(v)$(PRE_BUILD)
    endif

.PHONY: post-build
post-build: pre-build $(BUILD_DEPS) $(buildDir)/$(artifactName) $(_postBuildDeps) $(POST_BUILD_DEPS)
    ifneq ($(POST_BUILD), )
	    $(v)$(POST_BUILD)
    endif
# ==============================================================================

# CLEAN ========================================================================
.PHONY: clean
clean: post-clean

.PHONY: pre-clean
pre-clean:
    ifneq ($(PRE_CLEAN), )
	    $(v)$(PRE_CLEAN)
    endif

.PHONY: post-clean
post-clean: pre-clean
	$(v)rm -rf $(BUILD_DIR_BASE) $(DIST_DIR_BASE)
    ifneq ($(POST_CLEAN), )
	    $(v)$(POST_CLEAN)
    endif
# ==============================================================================

# DIST =========================================================================
.PHONY: dist
dist: post-dist

.PHONY: pre-dist
pre-dist: $(PRE_DIST_DEPS)
    ifneq ($(PRE_DIST), )
	    $(v)$(PRE_DIST)
    endif

.PHONY: post-dist
post-dist: pre-dist $(DIST_DEPS) build $(_postDistDeps) $(POST_DIST_DEPS)
    ifneq ($(POST_DIST), )
	    $(v)$(POST_DIST)
    endif
# ==============================================================================

# _postDistDeps ================================================================
ifeq ($(PROJ_TYPE), lib)
$(distDir)/%.h : %.h
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(dir $@)
	$(v)ln -f $< $@
endif

ifeq ($(PROJ_TYPE), app)
$(distDir)/bin/$(artifactName): $(buildDir)/$(artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/bin
	$(v)ln -f $< $@
endif

ifeq ($(PROJ_TYPE), lib)
$(distDir)/lib/$(artifactName): $(buildDir)/$(artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@
endif
# ==============================================================================

# Build artifact ===============================================================
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

# C sources ====================================================================
$(buildDir)/%.c$(objSuffix): %.c
	@printf "$(nl)[CC] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CC) $(strip $(_cFlags) -MMD $(CFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

# C++ sources ==================================================================
$(buildDir)/%.cpp$(objSuffix): %.cpp
	@printf "$(nl)[CXX] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CXX) $(strip $(_cxxFlags) -MMD -MP $(CXXFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

# Assembly sources =============================================================
$(buildDir)/%.S$(objSuffix): %.S
	@printf "$(nl)[AS] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(AS) $(strip $(_asFlags) -MMD $(ASFLAGS) $(_includeFlags) -c $< -o $@)
# ==============================================================================

-include $(_deps)

endif # _include_project_mk

