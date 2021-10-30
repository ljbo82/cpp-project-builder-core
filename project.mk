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

ifndef __include_project_mk__
__include_project_mk__ := 1

# ------------------------------------------------------------------------------
ifneq (1,$(words $(shell pwd)))
    $(error Current directory ($(shell pwd)) contains one or more whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ifeq ($(__R__),1) identifies a recursive call
# This flag is used for performance optimization on dependency inspections
ifeq ($(__R__),)
    __R__ := 0
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__project_mk_dir__ := $(dir $(lastword $(MAKEFILE_LIST)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
include $(__project_mk_dir__)common.mk
include $(__project_mk_dir__)functions.mk
include $(__project_mk_dir__)native_host.mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
defaultLibType               := shared
defaultProjVersion           := 0.1.0
defaultDebug                 := 0
defaultOutputDirBase         := output
defaultSrcDir                := src
defaultIncludeDir            := include
defaultHostsDir              := hosts
defaultHostMkRequired        := 0
defaultStripRelease          := 1
defaultOptimizeRelease       := 1
defaultOptimizationLevel     := 2
defaultSkipDefaultSrcDir     := 0
defaultSkipDefaultIncludeDir := 0
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_NAME),)
    $(error Missing PROJ_NAME)
endif

ifneq (1,$(words $(PROJ_NAME)))
    $(error PROJ_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE),)
    $(error Missing PROJ_TYPE)
endif
ifneq ($(PROJ_TYPE),app)
    ifneq ($(PROJ_TYPE),lib)
        $(error Unsupported PROJ_TYPE: $(PROJ_TYPE))
    else
        ifeq ($(LIB_TYPE),)
            LIB_TYPE := $(defaultLibType)
        endif
        ifneq ($(LIB_TYPE),shared)
            ifneq ($(LIB_TYPE),static)
                $(error Unsupported LIB_TYPE: $(LIB_TYPE))
            endif
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_VERSION),)
    PROJ_VERSION := $(defaultProjVersion)
endif

ifeq ($(call fn_version_valid,$(PROJ_VERSION)),0)
    $(error Invalid PROJ_VERSION: $(PROJ_VERSION))
endif

projVersionMajor := $(call fn_version_major,$(PROJ_VERSION))
projVersionMinor := $(call fn_version_minor,$(PROJ_VERSION))
projVersionPatch := $(call fn_version_patch,$(PROJ_VERSION))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DEBUG),)
    DEBUG := $(defaultDebug)
endif

ifneq ($(DEBUG),0)
    ifneq ($(DEBUG),1)
        $(error Invalid value for DEBUG: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(STRIP_RELEASE),)
    STRIP_RELEASE := $(defaultStripRelease)
endif

ifneq ($(STRIP_RELEASE),0)
    ifneq ($(STRIP_RELEASE),1)
        $(error Invalid value for STRIP_RELEASE: $(STRIP_RELEASE))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(OPTIMIZE_RELEASE),)
    OPTIMIZE_RELEASE := $(defaultOptimizeRelease)
endif

ifneq ($(OPTIMIZE_RELEASE),0)
    ifneq ($(OPTIMIZE_RELEASE),1)
        $(error Invalid value for OPTIMIZE_RELEASE: $(OPTIMIZE_RELEASE))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(OPTIMIZATION_LEVEL),)
    OPTIMIZATION_LEVEL := $(defaultOptimizationLevel)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST),)
    ifeq ($(nativeOS),)
        $(error Cannot detect native operating system)
    endif

    ifeq ($(nativeArch),)
        $(error Cannot detect native architecture)
    endif

    hostOS   := $(nativeOS)
    hostArch := $(nativeArch)

    HOST := $(hostOS)-$(hostArch)
else
    ifeq ($(call fn_host_valid,$(HOST)),0)
        $(error Invalid HOST: $(HOST))
    endif

    hostOS   := $(call fn_host_os,$(HOST))
    hostArch := $(call fn_host_arch,$(HOST))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(O),)
    O := $(defaultOutputDirBase)
endif

ifneq (1,$(words $(O)))
    $(error Output directory ($(O)) cannot have whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
buildDir := $(O)/build/$(HOST)
ifneq ($(strip $(BUILD_DIR)),)
    buildDir := $(buildDir)/$(strip $(BUILD_DIR))
endif

distDir := $(O)/dist/$(HOST)
ifneq ($(strip $(DIST_DIR)),)
    distDir := $(distDir)/$(strip $(DIST_DIR))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_SRC_DIR),)
    SKIP_DEFAULT_SRC_DIR := $(defaultSkipDefaultSrcDir)
endif

ifneq ($(SKIP_DEFAULT_SRC_DIR),0)
    ifneq ($(SKIP_DEFAULT_SRC_DIR),1)
        $(error Invalid value for SKIP_DEFAULT_SRC_DIR: $(SKIP_DEFAULT_SRC_DIR))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),)
    SKIP_DEFAULT_INCLUDE_DIR := $(defaultSkipDefaultIncludeDir)
endif

ifneq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
    ifneq ($(SKIP_DEFAULT_INCLUDE_DIR),1)
        $(error Invalid value for SKIP_DEFAULT_INCLUDE_DIR: $(SKIP_DEFAULT_INCLUDE_DIR))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_SRC_DIR),0)
    ifneq ($(wildcard $(defaultSrcDir)),)
        SRC_DIRS += $(defaultSrcDir)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(SKIP_DEFAULT_INCLUDE_DIR),0)
    ifneq ($(wildcard $(defaultIncludeDir)),)
        ifeq ($(PROJ_TYPE),lib)
            DIST_INCLUDE_DIRS += $(defaultIncludeDir)
        endif

        INCLUDE_DIRS += $(defaultIncludeDir)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(ARTIFACT_BASE_NAME),)
    ifeq ($(DEBUG),1)
        __debugSuffix__ := _d
    endif

    ARTIFACT_BASE_NAME := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix__)
    undefine __debugSuffix__
endif

ifneq (1,$(words $(ARTIFACT_BASE_NAME)))
    $(error ARTIFACT_BASE_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOSTS_DIR),)
    HOSTS_DIR := $(defaultHostsDir)
endif

ifneq (1,$(words $(HOSTS_DIR)))
    $(error HOSTS_DIR ($(HOSTS_DIR)) cannot have whitespaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK_REQUIRED),)
    HOST_MK_REQUIRED := $(defaultHostMkRequired)
endif

ifneq ($(HOST_MK_REQUIRED),0)
    ifneq ($(HOST_MK_REQUIRED),1)
        $(error Invalid value for HOST_MK_REQUIRED: $(HOST_MK_REQUIRED))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK),)
    ifneq ($(wildcard $(HOSTS_DIR)/$(HOST).mk),)
        HOST_MK := $(HOST).mk
    else
        ifneq ($(wildcard $(HOSTS_DIR)/$(hostOS).mk),)
            HOST_MK := $(hostOS).mk
        endif
    endif
else
    ifeq ($(wildcard $(HOSTS_DIR)/$(HOST_MK)),)
        $(error [HOST_MK] No such file: $(HOSTS_DIR)/$(HOST_MK))
    endif
endif

ifneq ($(HOST_MK),)
    include $(HOSTS_DIR)/$(HOST_MK)
else
    ifeq ($(HOST_MK_REQUIRED),1)
        __preBuildError__ := Unsupported HOST: $(HOST)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R__),0)
    # Source file scanning is not required on recursive calls
    SRC_DIRS := $(sort $(SRC_DIRS))
    SRC_DIRS := $(filter-out $(SKIPPED_SRC_DIRS),$(SRC_DIRS))
    $(foreach srcDir,$(SRC_DIRS),$(if $(call fn_subdir,$(srcDir),$(shell pwd)),,$(error Source directory ($(srcDir)) is outside project tree)))
    srcFiles := $(sort $(strip $(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f -name '*.c' -or -name '*.cpp' -or -name '*.S' 2> /dev/null))))
    srcFiles := $(filter-out $(SKIPPED_SRC_FILES),$(srcFiles))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(BUILDER_HOST_MK),)
    ifneq ($(wildcard $(__project_mk_dir__)$(defaultHostsDir)/$(HOST).mk),)
        BUILDER_HOST_MK := $(__project_mk_dir__)$(defaultHostsDir)/$(HOST).mk
    else
        ifneq ($(wildcard $(__project_mk_dir__)$(defaultHostsDir)/$(hostOS).mk),)
            BUILDER_HOST_MK := $(__project_mk_dir__)$(defaultHostsDir)/$(hostOS).mk
        endif
    endif
else
    ifeq ($(wildcard $(BUILDER_HOST_MK)),)
        $(error [BUILDER_HOST_MK] No such file: $(BUILDER_HOST_MK))
    endif
endif

ifneq ($(BUILDER_HOST_MK),)
    include $(BUILDER_HOST_MK)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(HOST_MK),)
    ifeq ($(BUILDER_HOST_MK),)
        __preBuildError__ := Unsupported HOST: $(HOST)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(ARTIFACT_NAME),)
    ARTIFACT_NAME := $(ARTIFACT_BASE_NAME)
endif

ifneq (1,$(words $(ARTIFACT_NAME)))
    $(error ARTIFACT_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DEBUG),1)
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
            objSuffix := .dbg.lo
        else
            objSuffix := .dbg.o
        endif
    else
        objSuffix := .dbg.o
    endif
else
    ifeq ($(PROJ_TYPE),lib)
        ifeq ($(LIB_TYPE),shared)
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
ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),shared)
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
# $(call __postDistDeps_template__,destinationFileInDistDir,sourceFile)
define __postDistDeps_template__=
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
ifneq ($(srcFiles),)
    ifeq ($(PROJ_TYPE),app)
        distFiles += bin/$(ARTIFACT_NAME):$(buildDir)/$(ARTIFACT_NAME)
    else
        distFiles += lib/$(ARTIFACT_NAME):$(buildDir)/$(ARTIFACT_NAME)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
cFlags   += -Wall
cxxFlags += -Wall

ifeq ($(DEBUG),1)
    cFlags   += -g3
    cxxFlags += -g3
    asFlags  += -g3
else
    ifeq ($(OPTIMIZE_RELEASE),1)
        cFlags   += -O$(OPTIMIZATION_LEVEL)
        cxxFlags += -O$(OPTIMIZATION_LEVEL)
    endif

    ifeq ($(STRIP_RELEASE),1)
        cFlags   += -s
        cxxFlags += -s
        ldFlags  += -s
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE),lib)
    ifeq ($(LIB_TYPE),shared)
        cFlags   += -fPIC
        cxxFlags += -fPIC
        ldFlags  += -shared
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Declared dependencies on linker-wide libraries
LIBS := $(call fn_unique,$(LIBS))

# Declared dependency on library projects
#
# Entry sintax:
#     project_dir[:makefile[:target[:env_var1=env_var1[:env_var2=env_var2]...]]]]
#
# Default values:
#     makefile: Makefile
#     target: none (use makefile's default target)
LIB_PROJ_DIRS := $(strip $(call fn_unique,$(LIB_PROJ_DIRS)))

ifneq ($(LIB_PROJ_DIRS),)
    ldFlags      += -L$(O)/dist/$(HOST)/lib
    INCLUDE_DIRS += $(O)/dist/$(HOST)/include
endif

ifneq ($(or $(LIB_PROJ_DIRS),$(LIBS)),)
    ldFlags += -Wl,--as-needed
endif

# Syntax: $(call __fn_lib_proj_dir__,projDirEntry)
# Return: The directory for projDirEntry
__fn_lib_proj_dir__ = $(call fn_cut,$(1):,:,1)

# Syntax: $(call __fn_lib_proj_makefile__,projDirEntry)
# Return: The makefile associated with projDirentry
__fn_lib_proj_makefile__ = $(if $(call fn_cut,$(1),:,2),-f $(call fn_cut,$(1),:,2))

# Syntax: $(call __fn_lib_proj_target__,projDirEntry)
# Return: The makefile target associated with projDirentry
__fn_lib_proj_target__ = $(if $(call fn_cut,$(1),:,3),$(call fn_cut,$(1),:,3))

# Syntax: $(call __fn_lib_proj_environment__,projDirEntry)
# Return: The environment to be passed while getting info from given projDirEntry)
__fn_lib_proj_environment__ = $(strip $(subst :, ,$(call fn_cut,$(1),:,4-)))

# Syntax $(call __fn_lib_proj_info__,projDirEntry,variables)
# Return: requested variabled
__fn_lib_proj_info__ = $(shell $(MAKE) -s --no-print-directory -C $(call __fn_lib_proj_dir__,$(1)) $(call __fn_lib_proj_makefile__,$(1)) printvars __R__=1 HOST=$(HOST) DEBUG=$(DEBUG) VARS='$(2)' $(call __fn_lib_proj_environment__,$(1)))

# Checks only direct dependencies
ifeq ($(__R__),0)
    $(foreach libProjDir,$(LIB_PROJ_DIRS),$(if $(wildcard $(call __fn_lib_proj_dir__,$(libProjDir))),,$(error LIB_PROJ_DIRS: '$(libProjDir)' not found)))
    $(foreach libProjDir,$(LIB_PROJ_DIRS),$(if $(call fn_eq,lib,$(call __fn_lib_proj_info__,$(libProjDir),PROJ_TYPE)),,$(error LIB_PROJ_DIRS: '$(libProjDir)' is not a library project)))
endif

# This is required to be enabled even on recursive calls in order to resolve
# transient dependencies
libs := $(strip $(call fn_unique,$(foreach lib,$(LIBS),$(lib)) $(foreach libProjDir,$(LIB_PROJ_DIRS),$(call __fn_lib_proj_info__,$(libProjDir),ARTIFACT_BASE_NAME libs))))

ldFlags += $(foreach lib,$(libs),-l$(lib))

ifeq ($(__R__),0)
# Syntax: $(call __libProjDeps_template__,libProjDirEntry,libProjDirProjName libProjDirArtifactName)
define __libProjDeps_template__ =
buildDeps += __lib_$(call fn_word,$(2),1)__

# Library BUILD_DEPS ===========================================================
.PHONY: __lib_$(call fn_word,$(2),1)__
__lib_$(call fn_word,$(2),1)__:
	@printf "$$(nl)[LIBS] $$(O)/build/$$(HOST)/lib/$(call fn_word,$(2),1)\n"
	$$(v)$$(MAKE) -C $(call __fn_lib_proj_dir__,$(1)) $(call __fn_lib_proj_makefile__,$(1)) $(call __fn_lib_proj_target__,$(1)) O=$(abspath $(O)) BUILD_DIR=lib/$(call fn_word,$(2),1) HOST=$(HOST) DEBUG=$(DEBUG) $(call __fn_lib_proj_environment__,$(1))
# ==============================================================================
endef

$(foreach libProjDir,$(LIB_PROJ_DIRS),$(eval $(call __libProjDeps_template__,$(libProjDir),$(call __fn_lib_proj_info__,$(libProjDir),PROJ_NAME ARTIFACT_NAME))))
endif # ifeq ($(__R__),0)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
INCLUDE_DIRS := $(sort $(INCLUDE_DIRS))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R__),0)
    # Header file scanning is not required on recursive calls
    ifeq ($(PROJ_TYPE),lib)
        DIST_INCLUDE_DIRS := $(sort $(DIST_INCLUDE_DIRS))
        distFiles += $(strip $(foreach distIncludeDir,$(DIST_INCLUDE_DIRS),$(shell cd $(distIncludeDir); find . -type f -name '*.h' -or -name '*.hpp' 2> /dev/null | sed 's:./::' | xargs -I {} echo $(defaultIncludeDir)/\{\}:$(distIncludeDir)/\{\})))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
includeFlags += $(strip $(foreach srcDir,$(SRC_DIRS),-I$(srcDir)))

ifeq ($(PROJ_TYPE),lib)
    includeDirs = $(sort $(INCLUDE_DIRS) $(DIST_INCLUDE_DIRS))
else
    includeDirs = $(INCLUDE_DIRS)
endif

includeFlags += $(strip $(foreach includeDir,$(includeDirs),-I$(includeDir)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
arFlags += rcs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R__),0)
    isCppProject := $(strip $(foreach srcDir,$(SRC_DIRS),$(shell find $(srcDir) -type f -name *.cpp 2> /dev/null)))

    ifeq ($(isCppProject),)
        isCppProject = $(strip $(foreach includeDir,$(INCLUDE_DIRS),$(shell find $(includeDir) -type f -name *.hpp 2> /dev/null)))
    endif

    ifeq ($(isCppProject),)
        isCppProject := 0
    else
        isCppProject := 1
    endif

    CC  := gcc
    CXX := g++

    ifeq ($(isCppProject),0)
        # Pure C project
        LD := gcc
    else
        # C/C++ project
        LD := $(CXX)
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(__R__),0)
    ifeq ($(shell sh -c "$(CROSS_COMPILE)gcc -v > /dev/null 2>&1 && echo 1 || echo 0"),0)
        __preBuildError__ := $(CROSS_COMPILE)gcc is not in PATH
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
DIST_DIRS := $(strip $(sort $(DIST_DIRS)))
ifeq ($(__R__),0)
    distFiles += $(foreach tmpDistDir,$(DIST_DIRS),$(shell cd $(call fn_cut,$(tmpDistDir),:,2);find . -type f 2> /dev/null | sed 's:./::' | xargs -I {} echo $(call fn_cut,$(tmpDistDir),:,1)/\{\}:$(call fn_cut,$(tmpDistDir),:,2)/\{\}))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
distFiles := $(strip $(sort $(distFiles) $(DIST_FILES)))
ifeq ($(__R__),0)
    $(foreach distFile,$(distFiles),$(eval $(call __postDistDeps_template__,$(call fn_cut,$(distFile),:,1),$(call fn_cut,$(distFile),:,2))))
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(__preBuildError__),)
    preBuildDeps += __pre-build-error__
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
preCleanDeps  := $(strip $(preCleanDeps) $(PRE_CLEAN_DEPS))
cleanDeps     := $(strip $(cleanDeps) $(CLEAN_DEPS))
postCleanDeps := $(strip $(postCleanDeps) $(POST_CLEAN_DEPS))

preBuildDeps  := $(strip $(preBuildDeps) $(PRE_BUILD_DEPS))
buildDeps     := $(strip $(buildDeps) $(buildDir)/$(ARTIFACT_NAME) $(BUILD_DEPS))
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
ifeq ($(__R__),0)
.PHONY: all
all: dist
endif
# ==============================================================================

# printvars ====================================================================
.PHONY: printvars
printvars:
ifneq ($(words $(VARS)),0)
	@echo $(foreach var,$(VARS),$($(var)))
else
	$(error Missing VARS)
endif
# ==============================================================================

# clean ========================================================================
ifeq ($(__R__),0)
.PHONY: clean
clean: post-clean

.PHONY: pre-clean
pre-clean: $(preCleanDeps)

.PHONY: __clean__
__clean__: pre-clean $(cleanDeps)
	$(v)rm -rf $(O)

.PHONY: post-clean
post-clean: __clean__ $(postCleanDeps)
endif
# ==============================================================================

# build ========================================================================
ifeq ($(__R__),0)
.PHONY: build
build: post-build

ifneq ($(__preBuildError__),)
.PHONY: __pre-build-error__
__pre-build-error__:
	$(error $(__preBuildError__))
endif #ifneq ($(__preBuildError__),)

.PHONY: pre-build
pre-build: $(preBuildDeps)

.PHONY: __build__
__build__: pre-build $(buildDeps)

.PHONY: post-build
post-build: __build__ $(postBuildDeps)
endif
# ==============================================================================

# dist =========================================================================
ifeq ($(__R__),0)
.PHONY: dist
dist: post-dist

.PHONY: pre-dist
pre-dist: build $(preDistDeps)

.PHONY: __dist__
__dist__: pre-dist $(distDeps)

.PHONY: post-dist
post-dist: __dist__ $(postDistDeps)
endif
# ==============================================================================

# Build artifact ===============================================================
ifeq ($(__R__),0)
$(buildDir)/$(ARTIFACT_NAME): $(objFiles)
    ifneq ($(srcFiles),)
        ifeq ($(PROJ_TYPE),lib)
            ifeq ($(LIB_TYPE),shared)
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
endif
# ==============================================================================

# C sources ====================================================================
ifeq ($(__R__),0)
$(buildDir)/%.c$(objSuffix): %.c
	@printf "$(nl)[CC] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CC) $(cFlags) -c $< -o $@
endif
# ==============================================================================

# C++ sources ==================================================================
ifeq ($(__R__),0)
$(buildDir)/%.cpp$(objSuffix): %.cpp
	@printf "$(nl)[CXX] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(CXX) $(cxxFlags) -c $< -o $@
endif
# ==============================================================================

# Assembly sources =============================================================
ifeq ($(__R__),0)
$(buildDir)/%.S$(objSuffix): %.S
	@printf "$(nl)[AS] $@\n"
	@mkdir -p $(dir $@)
	$(v)$(CROSS_COMPILE)$(AS) $(asFlags) -c $< -o $@
endif
# ==============================================================================

-include $(depFiles)

endif # __include_project_mk__
