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

defaultLibType      := shared
defaultProjVersion  := 0.1.0
defaultDebug        := 0
defaultV            := 0
defaultBuildDirBase := build
defaultDistDirBase  := dist
defaultSrcDir       := src
defaultIncludeDir   := include
defaultOsDir        := os

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

ifeq ($(shell sh -c "echo $(PROJ_VERSION) | grep -oP '[0-9]+\.[0-9]+\.[0-9]+.*'"), )
    $(error Invalid PROJ_VERSION: $(PROJ_VERSION))
endif
projVersionMajor := $(shell echo $(PROJ_VERSION) | cut -d'.' -f1)
projVersionMinor := $(shell echo $(PROJ_VERSION) | cut -d'.' -f2)
projVersionPatch := $(shell echo $(PROJ_VERSION) | cut -d'.' -f3-)
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
__selfDir := $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(HOST), )
    include $(__selfDir)native_host.mk
else
    ifeq ($(shell echo $(HOST) | grep -oP '[a-zA-Z0-9]+\-[a-zA-Z0-9]+.*'), )
        $(error Invalid HOST: $(HOST))
    endif

    hostOS := $(shell echo $(HOST) | cut -d'-' -f1)
    hostArch := $(shell echo $(HOST) | cut -d'-' -f2-)
endif
HOST := $(hostOS)-$(hostArch)
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
    INCLUDE_DIRS += $(defaultIncludeDir)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(OS_DIR), )
    OS_DIR := $(defaultOsDir)
endif

__selfDir := $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(wildcard $(__selfDir)$(OS_DIR)/$(hostOS).mk), )
    $(error Unsupported host OS: $(hostOS))
endif
include $(__selfDir)$(OS_DIR)/$(hostOS).mk
# ------------------------------------------------------------------------------

.DEFAULT_GOAL := all

undefine __selfDir

endif # _include_defs_mk

