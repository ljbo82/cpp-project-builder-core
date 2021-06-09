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
ifneq (1, $(words $(shell pwd)))
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ifeq ($(__R), 1) identifies a recursive call
# This flag is used for performance optimization on dependency inspections
ifeq ($(__R), )
    override __R := 0
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
_project_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
include $(_project_mk_dir)common.mk
include $(_project_mk_dir)functions.mk
include $(_project_mk_dir)native_host.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
defaultLibType            := shared
defaultProjVersion        := 0.1.0
defaultDebug              := 0
defaultOutputDirBase      := output
defaultSrcDir             := src
defaultIncludeDir         := include
defaultHostsDir           := hosts
defaultHostMkRequired     := 0
defaultStripRelease       := 1
defaultOptimizeRelease    := 1
defaultOptimizationLevel  := 2
defaultSkipDefaultSrcDirs := 0
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
            override LIB_TYPE := $(defaultLibType)
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
    override PROJ_VERSION := $(defaultProjVersion)
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
    override DEBUG := $(defaultDebug)
endif

ifneq ($(DEBUG), 0)
    ifneq ($(DEBUG), 1)
        $(error Invalid value for DEBUG: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(STRIP_RELEASE), )
    override STRIP_RELEASE := $(defaultStripRelease)
endif

ifneq ($(STRIP_RELEASE), 0)
    ifneq ($(STRIP_RELEASE), 1)
        $(error Invalid value for STRIP_RELEASE: $(STRIP_RELEASE))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(OPTIMIZE_RELEASE), )
    override OPTIMIZE_RELEASE := $(defaultOptimizeRelease)
endif

ifneq ($(OPTIMIZE_RELEASE), 0)
    ifneq ($(OPTIMIZE_RELEASE), 1)
        $(error Invalid value for OPTIMIZE_RELEASE: $(OPTIMIZE_RELEASE))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(OPTIMIZATION_LEVEL), )
    override OPTIMIZATION_LEVEL := $(defaultOptimizationLevel)
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

    override HOST := $(hostOS)-$(hostArch)
else
    ifeq ($(call fn_host_valid, $(HOST)), 0)
        $(error Invalid HOST: $(HOST))
    endif

    hostOS   := $(call fn_host_os, $(HOST))
    hostArch := $(call fn_host_arch, $(HOST))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(O), )
    override O := $(defaultOutputDirBase)
endif

ifneq (1, $(words $(O)))
    $(error Output directory ($(O)) cannot have whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
buildDir := $(O)/build/$(HOST)
distDir  := $(O)/dist/$(HOST)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_SRC_DIRS), )
    override SKIP_DEFAULT_SRC_DIRS := $(defaultSkipDefaultSrcDirs)
endif

ifneq ($(SKIP_DEFAULT_SRC_DIRS), 0)
    ifneq ($(SKIP_DEFAULT_SRC_DIRS), 1)
        $(error Invalid value for SKIP_DEFAULT_SRC_DIRS: $(SKIP_DEFAULT_SRC_DIRS))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_SRC_DIRS), 0)
    ifneq ($(wildcard $(defaultSrcDir)), )
        SRC_DIRS += $(defaultSrcDir)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_SRC_DIRS), 0)
    ifneq ($(wildcard $(defaultIncludeDir)), )
        ifeq ($(PROJ_TYPE), lib)
            DIST_INCLUDE_DIRS += $(defaultIncludeDir)
        endif

        INCLUDE_DIRS += $(defaultIncludeDir)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(ARTIFACT_BASE_NAME), )
    ifeq ($(DEBUG), 1)
        __debugSuffix := _d
    else
        __debugSuffix :=
    endif

    override ARTIFACT_BASE_NAME := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)
    undefine __debugSuffix
endif

ifneq (1, $(words $(ARTIFACT_BASE_NAME)))
    $(error ARTIFACT_BASE_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOSTS_DIR), )
    override HOSTS_DIR := $(defaultHostsDir)
endif

ifneq (1, $(words $(HOSTS_DIR)))
    $(error HOSTS_DIR ($(HOSTS_DIR)) cannot have whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK_REQUIRED), )
    override HOST_MK_REQUIRED := $(defaultHostMkRequired)
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
        override HOST_MK := $(HOSTS_DIR)/$(HOST).mk
    else
        ifneq ($(wildcard $(HOSTS_DIR)/$(hostOS).mk), )
            override HOST_MK := $(HOSTS_DIR)/$(hostOS).mk
        else
            override HOST_MK :=
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
        override BUILDER_HOST_MK := $(_project_mk_dir)$(defaultHostsDir)/$(HOST).mk
    else
        ifneq ($(wildcard $(_project_mk_dir)$(defaultHostsDir)/$(hostOS).mk), )
            override BUILDER_HOST_MK := $(_project_mk_dir)$(defaultHostsDir)/$(hostOS).mk
        else
            override BUILDER_HOST_MK :=
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
ifeq ($(ARTIFACT_NAME), )
    override ARTIFACT_NAME := $(ARTIFACT_BASE_NAME)
endif

ifneq (1, $(words $(ARTIFACT_NAME)))
    $(error ARTIFACT_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R), 0)
    # Source file scanning is not required on recursive calls
    SRC_DIRS := $(sort $(SRC_DIRS))
    $(foreach srcDir, $(SRC_DIRS), $(if $(call fn_subdir, $(srcDir), $(shell pwd)),,$(error Source directory ($(srcDir)) is outside project tree)))
    srcFiles := $(sort $(strip $(foreach srcDir, $(SRC_DIRS), $(shell find $(srcDir) -type f -name '*.c' -or -name '*.cpp' -or -name '*.S' 2> /dev/null))))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DEBUG), 1)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            objSuffix := .dbg.lo
        else
            objSuffix := .dbg.o
        endif
    else
        objSuffix := .dbg.o
    endif
else
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            objSuffix := .lo
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
ifeq ($(PROJ_TYPE), lib)
    ifeq ($(LIB_TYPE), shared)
        depFiles := $(objFiles:.lo=.d)
    else
        depFiles := $(objFiles:.o=.d)
    endif
else
    depFiles := $(objFiles:.o=.d)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Template for distribution artifacts (executed on post-dir target)
# $(call postDistDeps_template,destinationFileInDistDir,sourceFile)
define postDistDeps_template=
# ==============================================================================
postDistDeps += $$(distDir)/$(1)

$$(distDir)/$(1): $(2)
	@printf "$$(nl)[DIST] $$@\n"
	@mkdir -p $$(dir $$@)
	$$(v)ln -f $$< $$@
# ==============================================================================
endef
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), app)
    distFiles += bin/$(ARTIFACT_NAME):$(buildDir)/$(ARTIFACT_NAME)
else
    distFiles += lib/$(ARTIFACT_NAME):$(buildDir)/$(ARTIFACT_NAME)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
cFlags   += -Wall
cxxFlags += -Wall

ifeq ($(DEBUG), 1)
    cFlags   += -g3
    cxxFlags += -g3
    asFlags  += -g3
else
    ifeq ($(OPTIMIZE_RELEASE), 1)
        cFlags   += -O$(OPTIMIZATION_LEVEL)
        cxxFlags += -O$(OPTIMIZATION_LEVEL)
    endif

    ifeq ($(STRIP_RELEASE), 1)
        cFlags   += -s
        cxxFlags += -s
        ldFlags  += -s
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), lib)
    ifeq ($(LIB_TYPE), shared)
        cFlags   += -fPIC
        cxxFlags += -fPIC
        ldFlags  += -shared
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
LIBS := $(sort $(LIBS))

ifneq ($(LIBS), )
    ldFlags      += -L$(O)/dist/$(HOST)/lib -Wl,--as-needed
    INCLUDE_DIRS += $(O)/dist/$(HOST)/include
endif

# Checks only direct dependencies
ifeq ($(__R), 0)
    $(foreach lib,$(LIBS),$(if $(wildcard $(lib)),,$(error LIBS: '$(lib)' not found)))
    $(foreach lib,$(LIBS),$(if $(call fn_eq,lib,$(shell sh -c "$(MAKE) -s --no-print-directory -C $(lib) printvars __R=1 VARS=PROJ_TYPE")),,$(error LIBS: '$(lib)' is not a library project)))
endif

# This is required to be enabled even on recursive calls in order to resolve
# transient dependencies
libs := $(strip $(sort $(foreach lib,$(LIBS),$(if $(wildcard $(lib)),$(shell sh -c "$(MAKE) -s --no-print-directory -C $(lib) __R=1 DEBUG=$(DEBUG) printvars VARS='ARTIFACT_BASE_NAME libs'")))))

ldFlags += $(foreach lib,$(libs),-l$(lib))

ifeq ($(__R), 0)
# $(call lib_template,libPath,spaceDelimitedParameters)
# $(2): Space-delimited parameters:
    # 1) PROJ_NAME
    # 2) ARTIFACT_NAME
define lib_template =
$(call fn_word,$(2),1)_artifactName := $(call fn_word,$(2),2)

buildDeps += $$(O)/dist/$$(HOST)/lib/$$($(call fn_word,$(2),1)_artifactName)

# Library BUILD_DEPS ===========================================================
$$(O)/dist/$$(HOST)/lib/$$($(call fn_word,$(2),1)_artifactName):
	@printf "$$(nl)[LIBS] $$@\n"
	$$(v)$$(MAKE) -C $(1) O=$(abspath $(O))
# ==============================================================================
endef

$(foreach lib,$(LIBS),$(eval $(call lib_template,$(lib),$(shell sh -c "$(MAKE) -s --no-print-directory -C $(lib) printvars __R=1 DEBUG=$(DEBUG) LIB_TYPE=$(LIB_TYPE) VARS='PROJ_NAME ARTIFACT_NAME'"))))
endif # ifeq ($(__R), 0)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
INCLUDE_DIRS := $(sort $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R), 0)
    # Header file scanning is not required on recursive calls
    ifeq ($(PROJ_TYPE), lib)
        DIST_INCLUDE_DIRS := $(sort $(DIST_INCLUDE_DIRS))
        distFiles += $(strip $(foreach distIncludeDir, $(DIST_INCLUDE_DIRS), $(shell sh -c "cd $(distIncludeDir); find . -type f -name '*.h' -or -name '*.hpp' 2> /dev/null | sed 's:./::' | xargs -I {} echo $(defaultIncludeDir)/\{\}:$(distIncludeDir)/\{\}")))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
includeFlags += $(strip $(foreach srcDir, $(SRC_DIRS), -I$(srcDir)))

ifeq ($(PROJ_TYPE), lib)
    includeDirs = $(sort $(INCLUDE_DIRS) $(DIST_INCLUDE_DIRS))
else
    includeDirs = $(INCLUDE_DIRS)
endif

includeFlags += $(strip $(foreach includeDir, $(includeDirs), -I$(includeDir)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
arFlags += rcs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R), 0)
    isCppProject := $(strip $(foreach srcDir, $(SRC_DIRS), $(shell find $(srcDir) -type f -name *.cpp 2> /dev/null)))

    ifeq ($(isCppProject), )
        isCppProject = $(strip $(foreach includeDir, $(INCLUDE_DIRS), $(shell find $(includeDir) -type f -name *.hpp 2> /dev/null)))
    endif

    ifeq ($(isCppProject), )
        isCppProject := 0
    else
        isCppProject := 1
    endif

    CC  := gcc
    CXX := g++

    ifeq ($(isCppProject), 0)
        # Pure C project
        LD := gcc
    else
        # C/C++ project
        LD := $(CXX)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R), 0)
    ifeq ($(shell sh -c "$(CROSS_COMPILE)gcc -v > /dev/null 2>&1 && echo 1 || echo 0"), 0)
        $(error $(CROSS_COMPILE)gcc is not in PATH)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
cFlags   := $(strip -MMD -MP $(includeFlags) $(cFlags) $(CFLAGS))
cxxFlags := $(strip -MMD -MP $(includeFlags) $(cxxFlags) $(CXXFLAGS))
asFlags  := $(strip -MMD -MP $(includeFlags) $(asFlags) $(ASFLAGS))
arFlags  := $(strip $(arFlags))# By default ARFLAGS includes rv
ldFlags  := $(strip $(ldFlags) $(LDFLAGS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
distFiles := $(strip $(sort $(distFiles) $(DIST_FILES)))

ifeq ($(__R), 0)
    $(foreach distFile,$(distFiles),$(eval $(call postDistDeps_template,$(call fn_cut,$(distFile),:,1),$(call fn_cut,$(distFile),:,2))))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
preBuildDeps  := $(strip $(preBuildDeps) $(PRE_BUILD_DEPS))
buildDeps     := $(strip $(buildDeps) $(BUILD_DEPS))
postBuildDeps := $(strip $(postBuildDeps) $(POST_BUILD_DEPS))

preDistDeps   := $(strip $(preDistDeps) $(PRE_DIST_DEPS))
distDeps      := $(strip $(distDeps) $(DIST_DEPS))
postDistDeps  := $(strip $(postDistDeps) $(POST_DIST_DEPS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
.DEFAULT_GOAL := all

.NOTPARALLEL:
# ------------------------------------------------------------------------------

# all ==========================================================================
ifeq ($(__R), 0)
.PHONY: all
all: dist
endif
# ==============================================================================

# printvars ====================================================================
.PHONY: printvars
printvars:
ifneq ($(words $(VARS)), 0)
	@echo $(foreach var,$(VARS),$($(var)))
else
	$(error Missing VARS)
endif
# ==============================================================================

# build ========================================================================
ifeq ($(__R), 0)
.PHONY: build
build: post-build

.PHONY: pre-build
pre-build: $(preBuildDeps)
    ifneq ($(preBuild), )
	    @$(preBuild)
    endif
    ifneq ($(PRE_BUILD), )
	    $(v)$(PRE_BUILD)
    endif

.PHONY: post-build
post-build: pre-build $(buildDir)/$(ARTIFACT_NAME) $(postBuildDeps)
    ifneq ($(POST_BUILD), )
	    $(v)$(POST_BUILD)
    endif
endif
# ==============================================================================

# clean ========================================================================
ifeq ($(__R), 0)
.PHONY: clean
clean: post-clean

.PHONY: pre-clean
pre-clean:
    ifneq ($(PRE_CLEAN), )
	    $(v)$(PRE_CLEAN)
    endif

.PHONY: post-clean
post-clean: pre-clean
	$(v)rm -rf $(O)
    ifneq ($(POST_CLEAN), )
	    $(v)$(POST_CLEAN)
    endif
endif
# ==============================================================================

# dist =========================================================================
ifeq ($(__R), 0)
.PHONY: dist
dist: post-dist

.PHONY: pre-dist
pre-dist: build $(preDistDeps)
    ifneq ($(PRE_DIST), )
	    $(v)$(PRE_DIST)
    endif

.PHONY: post-dist
post-dist: pre-dist $(DIST_DEPS) $(postDistDeps)
    ifneq ($(POST_DIST), )
	    $(v)$(POST_DIST)
    endif
endif
# ==============================================================================

# Build artifact ===============================================================
ifeq ($(__R), 0)
$(buildDir)/$(ARTIFACT_NAME): $(buildDeps) $(objFiles)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
	        @printf "$(nl)[LD] $@\n"
	        $(v)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(objFiles) $(ldFlags))
        else
	        @printf "$(nl)[AR] $@\n"
	        $(v)$(CROSS_COMPILE)$(AR) $(strip $(arFlags) $@ $(objFiles))
        endif
    else
	    @printf "$(nl)[LD] $@\n"
	    $(v)$(CROSS_COMPILE)$(LD) $(strip -o $@ $(objFiles) $(ldFlags))
    endif
endif
# ==============================================================================

# C sources ====================================================================
ifeq ($(__R), 0)
$(buildDir)/%.c$(objSuffix): %.c
	@printf "$(nl)[CC] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CC) $(cFlags) -c $< -o $@
endif
# ==============================================================================

# C++ sources ==================================================================
ifeq ($(__R), 0)
$(buildDir)/%.cpp$(objSuffix): %.cpp
	@printf "$(nl)[CXX] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CXX) $(cxxFlags) -c $< -o $@
endif
# ==============================================================================

# Assembly sources =============================================================
ifeq ($(__R), 0)
$(buildDir)/%.S$(objSuffix): %.S
	@printf "$(nl)[AS] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(AS) $(asFlags) -c $< -o $@
endif
# ==============================================================================

-include $(depFiles)

endif # _include_project_mk

