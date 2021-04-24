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

#$(error doxygen.mk)
#$(error git.mk)

ifndef __include_project_mk__
__include_project_mk__ := 1

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
            LIB_TYPE := shared
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
    PROJ_VERSION := 0.1.0
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
    DEBUG := 0
endif
ifneq ($(DEBUG), 0)
    ifneq ($(DEBUG), 1)
        $(error Invalid value for DEBUG: $(DEBUG))
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(V), )
    V := 0
endif
ifneq ($(V), 0)
    ifneq ($(V), 1)
        $(error ERROR: Invalid value for V: $(V))
    endif
endif

ifeq ($(V), 0)
    __v__  := @
    __nl__ :=
else
    __v__  :=
    __nl__ := \n
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__selfDir__ := $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(HOST), )
    include $(__selfDir__)native_host.mk
else
    ifeq ($(shell sh -c "echo $(HOST) | grep -oP '[a-zA-Z0-9]+\-[a-zA-Z0-9]+.*'"), )
        $(error Invalid HOST: $(HOST))
    endif

    hostOS := $(shell echo $(HOST) | cut -d'.' -f1)
    hostArch := $(shell echo $(HOST) | cut -d'.' -f2-)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(BUILD_DIR_BASE), )
    BUILD_DIR_BASE := build
endif
ifeq ($(BUILD_DIR), )
    fullBuildDir := $(BUILD_DIR_BASE)/$(host)
else
    fullBuildDir := $(BUILD_DIR_BASE)/$(BUILD_DIR)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(DIST_DIR_BASE), )
    DIST_DIR_BASE := dist
endif
ifeq ($(DIST_DIR), )
    fullDistDir := $(DIST_DIR_BASE)/$(host)
else
    fullDistDir := $(DIST_DIR_BASE)/$(DIST_DIR)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__selfDir__ := $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(wildcard $(__selfDir__)os/$(hostOS).mk), )
    $(error Unsupported host OS: $(hostOS))
endif

include $(__selfDir__)os/$(hostOS).mk
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(wildcard src), )
    srcDirs += src
endif
srcDirs += $(SRC_DIRS)
srcDirs := $(sort $(srcDirs))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__srcFiles__ := $(strip $(foreach srcDir, $(srcDirs), $(shell find $(srcDir) -type f -name *.c -or -name *.cpp -or -name *.S 2> /dev/null)))
ifeq ($(DEBUG), 1)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            __objSuffix__ := .pic.dbg.o
        else
            __objSuffix__ := .dbg.o
        endif
    else
        __objSuffix__ := .dbg.o
    endif
else
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
            __objSuffix__ := .pic.o
        else
            __objSuffix__ := .o
        endif
    else
        __objSuffix__ := .o
    endif
endif
__objFiles__ := $(__srcFiles__:%=$(fullBuildDir)/%$(__objSuffix__))
__deps__     := $(__objFiles__:.o=.d)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(wildcard include), )
    includeDirs  += include
    ifeq ($(PROJ_TYPE), lib)
        __libDistHeaders__ := $(shell find include -type f -name *.h -or -name *.hpp 2> /dev/null)
        __postDistDeps__   += $(foreach libDistHeader, $(__libDistHeaders__), $(fullDistDir)/$(libDistHeader))
    endif
endif
includeDirs += $(INCLUDE_DIRS)
includeDirs := $(sort $(includeDirs))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__cFlags__   += -Wall
__cxxFlags__ += -Wall
ifeq ($(DEBUG), 1)
    __cFlags__   += -g3
    __cxxFlags__ += -g3
    __asFlags__  += -g3
endif

__includeFlags__ += $(strip $(foreach srcDir, $(srcDirs), -I$(srcDir)))
__includeFlags__ += $(strip $(foreach includeDir, $(includeDirs), -I$(includeDir)))

ifeq ($(PROJ_TYPE), lib)
    ifeq ($(LIB_TYPE), shared)
        __cFlags__   += -fPIC
        __cxxFlags__ += -fPIC
        __ldFlags__  += -shared
    endif
endif

__arFlags__ += rcs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
isCppProject := $(strip $(foreach srcDir, $(srcDirs), $(shell find $(srcDir) -type f -name *.cpp 2> /dev/null)))
ifeq ($(isCppProject), )
    isCppProject = $(strip $(foreach includeDir, $(includeDirs), $(shell find $(includeDir) -type f -name *.hpp 2> /dev/null)))
endif

ifeq ($(isCppProject), )
    isCppProject := 0
else
    isCppProject := 1
endif

ifeq ($(isCppProject), 0)
    # Pure C project
    LD := $(CC)
else
    # C/C++ project
    LD := $(CXX)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifneq ($(GCC_PREFIX), )
    __gccPrefix__ := $(GCC_PREFIX)-
endif
CC  := $(__gccPrefix__)$(CC)
CXX := $(__gccPrefix__)$(CXX)
AS  := $(__gccPrefix__)$(AS)
AR  := $(__gccPrefix__)$(AR)
LD  := $(__gccPrefix__)$(LD)
# ------------------------------------------------------------------------------

.DEFAULT_GOAL := all

.PHONY: all
all: dist

# BUILD ========================================================================
.PHONY: build
build: post-build

.PHONY: pre-build
pre-build: __v__  := $(__v__)
pre-build: $(PRE_BUILD_DEPS)
    ifneq ($(PRE_BUILD), )
	    $(__v__)$(PRE_BUILD)
    endif

.PHONY: post-build
post-build: __v__  := $(__v__)
post-build: pre-build $(BUILD_DEPS) $(fullBuildDir)/$(artifactName) $(__postBuildDeps__) $(POST_BUILD_DEPS)
    ifneq ($(POST_BUILD), )
	    $(__v__)$(POST_BUILD)
    endif
# ==============================================================================

# CLEAN ========================================================================
.PHONY: clean
clean: post-clean

.PHONY: pre-clean
pre-clean: __v__  := $(__v__)
pre-clean:
    ifneq ($(PRE_CLEAN), )
	    $(__v__)$(PRE_CLEAN)
    endif

.PHONY: post-clean
post-clean: __v__  := $(__v__)
post-clean: pre-clean
	$(__v__)rm -rf $(BUILD_DIR_BASE) $(DIST_DIR_BASE)
    ifneq ($(POST_CLEAN), )
	    $(__v__)$(POST_CLEAN)
    endif
# ==============================================================================

# DIST =========================================================================
.PHONY: dist
dist: post-dist

.PHONY: pre-dist
pre-dist: __v__ := $(__v__)
pre-dist: $(PRE_DIST_DEPS)
    ifneq ($(PRE_DIST), )
	    $(__v__)$(PRE_DIST)
    endif

.PHONY: post-dist
post-dist: __v__ := $(__v__)
post-dist: pre-dist $(DIST_DEPS) build $(__postDistDeps__) $(POST_DIST_DEPS)
    ifneq ($(POST_DIST), )
	    $(__v__)$(POST_DIST)
    endif
# ==============================================================================

$(fullBuildDir)/$(artifactName): __objFiles__ := $(__objFiles__)
$(fullBuildDir)/$(artifactName): __nl__  := $(__nl__)
$(fullBuildDir)/$(artifactName): __v__ := $(__v__)
$(fullBuildDir)/$(artifactName): __ldFlags__ := $(__ldFlags__)
$(fullBuildDir)/$(artifactName): __arFlags__ := $(__arFlags__)
$(fullBuildDir)/$(artifactName):  $(__objFiles__)
    ifeq ($(PROJ_TYPE), lib)
        ifeq ($(LIB_TYPE), shared)
	        @printf "$(__nl__)[LD] $@\n"
	        $(__v__)$(LD) $(strip -o $@ $(__objFiles__) $(__ldFlags__) $(LDFLAGS))
        else
	        @printf "$(__nl__)[AR] $@\n"
	        $(__v__)$(AR) $(strip $(__arFlags__) $@ $(__objFiles__))
        endif
    else
	    @printf "$(__nl__)[LD] $@\n"
	    $(__v__)$(LD) $(strip -o $@ $(__objFiles__) $(__ldFlags__) $(LDFLAGS))
    endif

$(fullDistDir)/include/%.h: __nl__ := $(__nl__)
$(fullDistDir)/include/%.h: __v__  := $(__v__)
$(fullDistDir)/include/%.h : include/%.h
	@mkdir -p $(dir $@)
	@printf "$(__nl__)[DIST] $@\n"
	$(__v__)ln $< $@

$(fullBuildDir)/%.c$(__objSuffix__): __nl__           := $(__nl__)
$(fullBuildDir)/%.c$(__objSuffix__): __v__            := $(__v__)
$(fullBuildDir)/%.c$(__objSuffix__): __cFlags__       := $(__cFlags__)
$(fullBuildDir)/%.c$(__objSuffix__): __includeFlags__ := $(__includeFlags__)
$(fullBuildDir)/%.c$(__objSuffix__): %.c
	@mkdir -p $(dir $@)
	@printf "$(__nl__)[CC] $@\n"
	$(__v__)$(CC) $(strip $(__cFlags__) -MMD $(CFLAGS) $(__includeFlags__) -c $< -o $@)

$(fullBuildDir)/%.cpp$(__objSuffix__): __nl__           := $(__nl__)
$(fullBuildDir)/%.cpp$(__objSuffix__): __v__            := $(__v__)
$(fullBuildDir)/%.cpp$(__objSuffix__): __cxxFlags__     := $(__cxxFlags__)
$(fullBuildDir)/%.cpp$(__objSuffix__): __includeFlags__ := $(__includeFlags__)
$(fullBuildDir)/%.cpp$(__objSuffix__): %.cpp
	@mkdir -p $(dir $@)
	@printf "$(__nl__)[CXX] $@\n"
	$(__v__)$(CXX) $(strip $(__cxxFlags__) -MMD -MP $(CXXFLAGS) $(__includeFlags__) -c $< -o $@)

$(fullBuildDir)/%.S$(__objSuffix__): __nl__           := $(__nl__)
$(fullBuildDir)/%.S$(__objSuffix__): __v__            := $(__v__)
$(fullBuildDir)/%.S$(__objSuffix__): __asFlags__      := $(__asFlags__)
$(fullBuildDir)/%.S$(__objSuffix__): __includeFlags__ := $(__includeFlags__)
$(fullBuildDir)/%.S$(__objSuffix__): %.S
	@mkdir -p $(dir $@)
	@printf "$(__nl__)[AS] $@\n"
	$(__v__)$(AS) $(strip $(__asFlags__) -MMD $(ASFLAGS) $(__includeFlags__) -c $< -o $@)

-include $(__deps__)

undefine __v__
undefine __nl__
undefine __srcFiles__
undefine __objSuffix__
undefine __objFiles__
undefine __deps__
undefine __selfDir__
undefine __libDistHeaders__
undefine __postBuildDeps__
undefine __postDistDeps__
undefine __cFlags__
undefine __cxxFlags__
undefine __asFlags__
undefine __includeFlags__
undefine __ldFlags__
undefine __arFlags__
undefine __gccPrefix__

endif # __include_project_mk__

