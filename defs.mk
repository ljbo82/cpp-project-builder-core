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

ifndef _include_defs_mk
_include_defs_mk := 1

# ------------------------------------------------------------------------------
ifeq ($(_project_mk_dir), )
    $(error project.mk not included yet)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
include $(_project_mk_dir)functions.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
defaultLibType      := shared
defaultProjVersion  := 0.1.0
defaultDebug        := 0
defaultV            := 0
defaultBuildDirBase := build
defaultDistDirBase  := dist
defaultSrcDir       := src
defaultIncludeDir   := include
defaultHostsDir     := hosts
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
include $(_project_mk_dir)native_host.mk
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

.DEFAULT_GOAL := all

endif # _include_defs_mk

